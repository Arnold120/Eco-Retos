import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/social/social_models.dart';
import '../../data/services/busqueda_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../widgets/user_avatar.dart';
import 'cubit/community_cubit.dart';
import 'user_profile_screen.dart';
import 'widgets/follow_button.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';


class UsuariosScreen extends StatelessWidget {
  final int usuarioId;

  const UsuariosScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: MuroUsuariosView(usuarioId: usuarioId),
    );
  }
}



class MuroUsuariosView extends StatelessWidget {
  final int usuarioId;

  const MuroUsuariosView({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<SeguimientoService>();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Siguiendo'),
              Tab(text: 'Seguidores'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TodosLosUsuarios(usuarioId: usuarioId),
                _ListaUsuarios(
                  cargar: () => service.getSiguiendo(usuarioId),
                  vacio: 'Aún no sigues a nadie.',
                ),
                _ListaUsuarios(
                  cargar: () => service.getSeguidores(usuarioId),
                  vacio: 'Todavía no tienes seguidores.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaUsuarios extends StatefulWidget {
  final Future<List<UsuarioResumen>> Function() cargar;
  final String vacio;

  const _ListaUsuarios({required this.cargar, required this.vacio});

  @override
  State<_ListaUsuarios> createState() => _ListaUsuariosState();
}

class _ListaUsuariosState extends State<_ListaUsuarios> {
  List<UsuarioResumen>? _usuarios;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _error = null);
    try {
      final lista = await widget.cargar();
      if (!mounted) return;
      setState(() => _usuarios = lista);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _usuarios = const [];
        _error = 'No pudimos cargar los usuarios. Inténtalo nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return SocialErrorState(mensaje: _error!, onReintentar: _cargar);
    }
    final usuarios = _usuarios;
    if (usuarios == null) {
      return const PostCardSkeleton();
    }
    if (usuarios.isEmpty) {
      return SocialEmptyState(
        icono: Icons.people_outline,
        titulo: 'Sin usuarios',
        subtitulo: widget.vacio,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        itemCount: usuarios.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: dividerColor(context).withValues(alpha: 0.4),
        ),
        itemBuilder: (context, i) => _FilaUsuario(usuario: usuarios[i]),
      ),
    );
  }
}


class _TodosLosUsuarios extends StatefulWidget {
  final int usuarioId;

  const _TodosLosUsuarios({required this.usuarioId});

  @override
  State<_TodosLosUsuarios> createState() => _TodosLosUsuariosState();
}

class _TodosLosUsuariosState extends State<_TodosLosUsuarios> {
  List<UsuarioResumen>? _usuarios;
  Set<int> _ocultos = {};
  String? _error;

  String get _claveOcultos => 'sugerencias_ocultas_${widget.usuarioId}';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _error = null);
    try {
      final service = context.read<BusquedaService>();
      final prefs = await SharedPreferences.getInstance();
      final usuarios = await service.getUsuarios(excluir: widget.usuarioId);
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _ocultos = (prefs.getStringList(_claveOcultos) ?? const [])
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toSet();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _usuarios = const [];
        _error = 'No pudimos cargar los usuarios. Inténtalo nuevamente.';
      });
    }
  }

  Future<void> _quitarDeSugerencias(int usuarioId) async {
    final ocultos = Set<int>.of(_ocultos)..add(usuarioId);
    setState(() => _ocultos = ocultos);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _claveOcultos,
      ocultos.map((e) => e.toString()).toList(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se quitó de tus sugerencias')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return SocialErrorState(mensaje: _error!, onReintentar: _cargar);
    }
    final usuarios = _usuarios;
    if (usuarios == null) {
      return const PostCardSkeleton();
    }
    if (usuarios.isEmpty) {
      return const SocialEmptyState(
        icono: Icons.people_outline,
        titulo: 'Sin usuarios',
        subtitulo: 'Todavía no hay más usuarios registrados.',
      );
    }

    final siguiendo = context.watch<CommunityCubit>().state.siguiendoIds;
    final sugerencias = usuarios
        .where((u) => !siguiendo.contains(u.usuarioId))
        .where((u) => !_ocultos.contains(u.usuarioId))
        .take(10)
        .toList();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'Sugerencias para ti',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: textColor(context),
              ),
            ),
          ),
          if (sugerencias.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'No hay sugerencias por ahora. Sigue explorando el Muro Eco.',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondaryColor(context),
                ),
              ),
            )
          else
            ...sugerencias.map(
              (u) => _FilaUsuario(
                usuario: u,
                conSeguir: true,
                onQuitarSugerencia: () => _quitarDeSugerencias(u.usuarioId),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Todos los usuarios',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: textColor(context),
              ),
            ),
          ),
          ...usuarios.map((u) => _FilaUsuario(usuario: u, conSeguir: true)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


class _FilaUsuario extends StatelessWidget {
  final UsuarioResumen usuario;
  final bool conSeguir;
  final VoidCallback? onQuitarSugerencia;

  const _FilaUsuario({
    required this.usuario,
    this.conSeguir = false,
    this.onQuitarSugerencia,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        nombre: usuario.nombreUsuario,
        fotoUrl: usuario.fotoPerfil,
        radius: 22,
        onTap: () => abrirPerfilUsuario(context, usuario.usuarioId),
      ),
      title: Text(
        usuario.nombreUsuario,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(usernameSlug(usuario.nombreUsuario)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conSeguir)
            CommunityFollowButton(usuarioId: usuario.usuarioId),
          if (onQuitarSugerencia != null)
            IconButton(
              tooltip: 'Quitar de sugerencias',
              onPressed: onQuitarSugerencia,
              icon: const Icon(Icons.person_remove_outlined, size: 20),
            ),
          if (!conSeguir)
            const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: () => abrirPerfilUsuario(context, usuario.usuarioId),
    );
  }
}
