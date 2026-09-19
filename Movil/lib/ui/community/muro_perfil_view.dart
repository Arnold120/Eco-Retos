import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/social/social_models.dart';
import '../../data/services/perfil_social_service.dart';
import '../../data/services/social_service.dart';
import '../widgets/user_avatar.dart';
import 'widgets/post_card.dart';
import 'widgets/post_media.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';

/// Perfil estilo red social dentro del Muro Eco: foto grande, datos reales
/// del usuario y sus publicaciones ordenadas de la mas reciente a la mas
/// antigua.
class MuroPerfilView extends StatefulWidget {
  final int usuarioId;

  const MuroPerfilView({super.key, required this.usuarioId});

  @override
  State<MuroPerfilView> createState() => _MuroPerfilViewState();
}

class _MuroPerfilViewState extends State<MuroPerfilView> {
  final _scroll = ScrollController();

  PerfilPublicoResponse? _perfil;
  List<PublicacionResponse> _publicaciones = const [];
  bool _cargando = true;
  bool _cargandoMas = false;
  bool _hayMas = true;
  String? _error;
  int _pagina = 1;

  static const _tamanoPagina = 10;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _cargar();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      _cargarMas();
    }
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _pagina = 1;
    });
    try {
      final perfilService = context.read<PerfilSocialService>();
      final publicacionService = context.read<PublicacionService>();
      final perfil = await perfilService.getPerfilPublico(widget.usuarioId);
      final publicaciones = await publicacionService.getFeed(
        pagina: 1,
        tamano: _tamanoPagina,
        autorId: widget.usuarioId,
      );
      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _publicaciones = publicaciones;
        _hayMas = publicaciones.length >= _tamanoPagina;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No pudimos cargar tu perfil. Inténtalo nuevamente.';
      });
    }
  }

  Future<void> _cargarMas() async {
    if (_cargandoMas || !_hayMas || _cargando) return;
    setState(() => _cargandoMas = true);
    try {
      final publicacionService = context.read<PublicacionService>();
      final siguientes = await publicacionService.getFeed(
        pagina: _pagina + 1,
        tamano: _tamanoPagina,
        autorId: widget.usuarioId,
      );
      if (!mounted) return;
      final ids = _publicaciones.map((p) => p.publicacionId).toSet();
      final nuevas =
          siguientes.where((p) => !ids.contains(p.publicacionId)).toList();
      setState(() {
        _pagina += 1;
        _publicaciones = [..._publicaciones, ...nuevas];
        _hayMas = siguientes.length >= _tamanoPagina && nuevas.isNotEmpty;
        _cargandoMas = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoMas = false;
        _hayMas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _perfil == null) {
      return const PostCardSkeleton();
    }
    if (_error != null && _perfil == null) {
      return SocialErrorState(mensaje: _error!, onReintentar: _cargar);
    }
    final perfil = _perfil;
    if (perfil == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          _cabecera(context, perfil),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'Publicaciones',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: textColor(context),
              ),
            ),
          ),
          if (_publicaciones.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: SocialEmptyState(
                icono: Icons.article_outlined,
                titulo: 'Sin publicaciones todavía',
                subtitulo:
                    'Cuando compartas una acción ambiental aparecerá aquí.',
              ),
            )
          else
            ..._publicaciones.map(
              (p) => PostCard(
                key: ValueKey(p.publicacionId),
                post: p,
                usuarioId: widget.usuarioId,
              ),
            ),
          if (_cargandoMas)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cabecera(BuildContext context, PerfilPublicoResponse perfil) {
    final sec = textSecondaryColor(context);
    final nombre = perfil.nombreCompleto ?? perfil.nombreUsuario;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor(context).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          UserAvatar(
            nombre: perfil.nombreUsuario,
            fotoUrl: perfil.fotoPerfil,
            radius: 46,
            // Al tocar la foto se abre el visor; ahi esta el menu ⋮ con
            // la opcion de descargar la imagen original.
            onTap: perfil.fotoPerfil == null
                ? null
                : () => abrirVisorMultimedia(
                      // El visor incluye el menu ⋮ con "Descargar".
                      context,
                      [
                        (
                          url: perfil.fotoPerfil!,
                          tipo: 'imagen',
                          duracion: null,
                          poster: null,
                        ),
                      ],
                      0,
                      nombreSugerido: perfil.nombreUsuario,
                    ),
          ),
          const SizedBox(height: 12),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: textColor(context),
            ),
          ),
          Text(
            usernameSlug(perfil.nombreUsuario),
            style: TextStyle(color: sec, fontSize: 13),
          ),
          if (perfil.centroEducativo != null || perfil.grado != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (perfil.grado != null) perfil.grado!,
                if (perfil.centroEducativo != null) perfil.centroEducativo!,
              ].join(' · '),
              textAlign: TextAlign.center,
              style: TextStyle(color: sec, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat(context, '${perfil.cantidadPublicaciones}',
                  'Publicaciones'),
              _stat(context, '${perfil.cantidadSeguidores}', 'Seguidores'),
              _stat(context, '${perfil.cantidadSeguidos}', 'Siguiendo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String valor, String label) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: textColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textSecondaryColor(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
