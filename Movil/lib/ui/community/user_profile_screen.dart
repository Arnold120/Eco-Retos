import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/media_url.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/busqueda_service.dart';
import '../../data/services/calificacion_service.dart';
import '../../data/services/mensaje_service.dart';
import '../../data/services/perfil_social_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/social_service.dart';
import '../messages/conversation_screen.dart';
import '../widgets/user_avatar.dart';
import 'cubit/community_cubit.dart';
import 'cubit/public_profile_cubit.dart';
import 'widgets/follow_button.dart';
import 'widgets/post_card.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';
import 'widgets/post_media.dart';


void abrirPerfilUsuario(BuildContext context, int usuarioId) {
  final community = context.read<CommunityCubit>();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: community),
          BlocProvider(
            create: (ctx) => PublicProfileCubit(
              usuarioId: usuarioId,
              perfilService: ctx.read<PerfilSocialService>(),
              publicacionService: ctx.read<PublicacionService>(),
              seguimientoService: ctx.read<SeguimientoService>(),
              calificacionService: ctx.read<CalificacionService>(),
            )..load(),
          ),
        ],
        child: const UserProfileScreen(),
      ),
    ),
  );
}

class UserProfileScreen extends StatefulWidget {
  final int? usuarioId;
  final bool embebido;

  const UserProfileScreen({
    super.key,
    this.usuarioId,
    this.embebido = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  final _muroController = TextEditingController();
  late final TabController _tabController;
  bool _guardandoCalificacion = false;
  bool _publicandoMuro = false;
  int? _calificacionSeleccionada;
  bool _verPrivados = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _muroController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      context.read<PublicProfileCubit>().cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<PublicProfileCubit, PublicProfileState>(
      listenWhen: (a, b) =>
          a.error != b.error && b.error != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColorsDark.background : AppColors.background,
        appBar: widget.embebido ? null : AppBar(title: const Text('Perfil')),
        body: BlocBuilder<PublicProfileCubit, PublicProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.perfil == null) {
              return const PostCardSkeleton();
            }
            if (state.error != null && state.perfil == null) {
              return SocialErrorState(
                mensaje: state.error!,
                onReintentar: () =>
                    context.read<PublicProfileCubit>().load(),
              );
            }
            final perfil = state.perfil;
            if (perfil == null) return const SizedBox.shrink();

            return AnchoLectura(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<PublicProfileCubit>().load(),
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _cabecera(context, perfil),
                    _tabBar(),
                    ..._contenidoTab(context, perfil, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _usuarioIdPropio(BuildContext context) {
    try {
      return context.read<CommunityCubit>().usuarioId;
    } catch (_) {
      return 0;
    }
  }

  Widget _cabecera(BuildContext context, PerfilPublicoResponse perfil) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;


    final siguiendoGlobal = context.select<CommunityCubit, bool>(
      (c) => c.state.siguiendoIds.contains(perfil.usuarioId),
    );
    final delta = siguiendoGlobal == perfil.siguiendo
        ? 0
        : (siguiendoGlobal ? 1 : -1);
    final seguidores = (perfil.cantidadSeguidores + delta).clamp(0, 1 << 31);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
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
            radius: 38,
          ),
          const SizedBox(height: 12),
          Text(
            perfil.nombreCompleto ?? perfil.nombreUsuario,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: textColor(context),
            ),
          ),
          if (perfil.nombreCompleto != null)
            Text(
              usernameSlug(perfil.nombreUsuario),
              style: TextStyle(color: sec, fontSize: 13),
            ),
          if (perfil.centroEducativo != null ||
              perfil.grado != null) ...[
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
              _stat(
                context,
                '$seguidores',
                'Seguidores',
                onTap: () => _abrirListaUsuarios(
                  context,
                  perfil.usuarioId,
                  favoritos: false,
                ),
              ),
              _stat(
                context,
                '${perfil.cantidadSeguidos}',
                'Siguiendo',
                onTap: () => _abrirListaUsuarios(
                  context,
                  perfil.usuarioId,
                  favoritos: true,
                ),
              ),
            ],
          ),
          if (!perfil.esMiPerfil) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FollowButton(
                    siguiendo: siguiendoGlobal,
                    compacto: false,
                    onToggle: () => _alternarSeguir(perfil),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _abrirConversacion(context, perfil),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Mensaje'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    side: BorderSide(color: primaryOf(context)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _alternarSeguir(PerfilPublicoResponse perfil) async {
    final cubit = context.read<PublicProfileCubit>();
    final community = context.read<CommunityCubit>();
    await cubit.toggleSeguir();
    final actualizado = cubit.state.perfil;
    if (actualizado == null) return;
    community.sincronizarSeguimiento(perfil.usuarioId, actualizado.siguiendo);
  }

  Future<void> _abrirConversacion(
      BuildContext context, PerfilPublicoResponse perfil) async {
    try {
      final conversacion = await context
          .read<MensajeService>()
          .abrirConversacion(perfil.usuarioId);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(
            conversacionId: conversacion.conversacionId,
            usuarioId: context.read<CommunityCubit>().usuarioId,
            titulo: conversacion.otroNombreUsuario,
            fotoUrl: conversacion.otroFotoPerfil ?? perfil.fotoPerfil,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la conversación. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  Future<void> _abrirListaUsuarios(
    BuildContext context,
    int usuarioId, {
    required bool favoritos,
  }) async {
    final seguimientoService = context.read<SeguimientoService>();
    final elegido = await showModalBottomSheet<UsuarioResumen>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _ListaUsuariosSheet(
        titulo: favoritos ? 'Favoritos' : 'Seguidores',
        vacio: favoritos
            ? 'Este usuario todavía no sigue a nadie.'
            : 'Este usuario todavía no tiene seguidores.',
        cargar: () => favoritos
            ? seguimientoService.getSiguiendo(usuarioId)
            : seguimientoService.getSeguidores(usuarioId),
      ),
    );
    if (elegido != null && context.mounted) {
      abrirPerfilUsuario(context, elegido.usuarioId);
    }
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      child: Container(
        height: 51,
        decoration: BoxDecoration(
          color: surfaceCard(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor(context).withValues(alpha: 0.6),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: primaryOf(context).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorPadding: const EdgeInsets.all(3),
            labelColor: primaryOf(context),
            unselectedLabelColor: textSecondaryColor(context),
            labelStyle: const TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w600),
            labelPadding: EdgeInsets.zero,
            onTap: (_) => setState(() {}),
            tabs: [
              _tabMini(Icons.home_outlined, 'Inicio'),
              _tabMini(Icons.photo_library_outlined, 'Fotos'),
              _tabMini(Icons.video_library_outlined, 'Videos'),
              _tabMini(Icons.alternate_email, 'Menciones'),
              _tabMini(Icons.repeat, 'Compartido'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabMini(IconData icono, String texto) {
    return Tab(
      height: 47,
      icon: Icon(icono, size: 16),
      text: texto,
      iconMargin: const EdgeInsets.only(bottom: 2),
    );
  }

  List<Widget> _contenidoTab(
    BuildContext context,
    PerfilPublicoResponse perfil,
    PublicProfileState state,
  ) {
    switch (_tabController.index) {
      case 1:
        return _tabFotos(context, perfil, state);
      case 2:
        return _tabVideos(context, state);
      case 3:
        return _tabMenciones(context, perfil, state);
      case 4:
        return _tabCompartido(context, perfil, state);
      default:
        return _tabInicio(context, perfil, state);
    }
  }

  Widget _tituloSeccion(BuildContext context, String titulo, [int? cuenta]) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: textColor(context),
              ),
            ),
          ),
          if (cuenta != null)
            Text(
              '$cuenta',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: primaryOf(context),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _tabInicio(
    BuildContext context,
    PerfilPublicoResponse perfil,
    PublicProfileState state,
  ) {
    return [
      _seccionDetalles(context, perfil),
      _seccionCalificaciones(context, perfil, state),
      _seccionContacto(context, perfil),
      _tituloSeccion(context, 'Publicaciones', perfil.cantidadPublicaciones),
      if (state.publicaciones.isEmpty && !state.isLoading)
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: SocialEmptyState(
            icono: Icons.article_outlined,
            titulo: 'Sin publicaciones todavía',
            subtitulo:
                'Cuando comparta una acción ambiental aparecerá aquí.',
          ),
        )
      else
        ...state.publicaciones.map(
          (p) => PostCard(
            post: p,
            usuarioId: _usuarioIdPropio(context),
          ),
        ),
      if (state.isLoadingMore)
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
    ];
  }

  Widget _filaDetalle(
    BuildContext context, {
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    final sec = textSecondaryColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 19, color: primaryOf(context)),
          const SizedBox(width: 10),
          Text(
            etiqueta,
            style: TextStyle(color: sec, fontSize: 12.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: textColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionDetalles(
      BuildContext context, PerfilPublicoResponse perfil) {
    return PostCardContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: primaryOf(context)),
              const SizedBox(width: 8),
              Text(
                'Detalles',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _filaDetalle(
            context,
            icono: Icons.badge_outlined,
            etiqueta: 'Nombre',
            valor: perfil.nombreCompleto ?? perfil.nombreUsuario,
          ),
          if (perfil.grado != null)
            _filaDetalle(
              context,
              icono: Icons.class_outlined,
              etiqueta: 'Grado',
              valor: perfil.grado!,
            ),
          if (perfil.centroEducativo != null)
            _filaDetalle(
              context,
              icono: Icons.school_outlined,
              etiqueta: 'Centro',
              valor: perfil.centroEducativo!,
            ),
        ],
      ),
    );
  }

  Widget _seccionContacto(BuildContext context, PerfilPublicoResponse perfil) {
    final sec = textSecondaryColor(context);
    return PostCardContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_outlined,
                  size: 18, color: primaryOf(context)),
              const SizedBox(width: 8),
              Text(
                'Información de contacto',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (perfil.correo != null && perfil.correo!.trim().isNotEmpty)
            _filaDetalle(
              context,
              icono: Icons.mail_outline,
              etiqueta: 'Correo',
              valor: perfil.correo!,
            )
          else
            Text(
              'Este usuario no registró información de contacto.',
              style: TextStyle(color: sec, fontSize: 13),
            ),
        ],
      ),
    );
  }

  List<Widget> _tabFotos(
    BuildContext context,
    PerfilPublicoResponse perfil,
    PublicProfileState state,
  ) {
    final perfilFotos = <MultimediaItem>[
      if (perfil.fotoPerfil != null)
        (
          url: perfil.fotoPerfil!,
          tipo: 'imagen',
          duracion: null,
          poster: null,
        ),
    ];
    final publicadas = <MultimediaItem>[];
    final postsPublicadas = <PublicacionResponse?>[];
    for (final p in state.publicaciones) {
      for (final item in _fotosDe(p)) {
        publicadas.add(item);
        postsPublicadas.add(p);
      }
    }
    final todas = <MultimediaItem>[...perfilFotos, ...publicadas];
    final postsVisor = <PublicacionResponse?>[
      ...perfilFotos.map((_) => null),
      ...postsPublicadas,
    ];

    return [
      _tituloSeccion(context, 'Fotos de perfil', perfilFotos.length),
      if (perfilFotos.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Sin foto de perfil.'),
        )
      else
        _grupoGrilla(
          context,
          label: null,
          items: perfilFotos,
          visorTodos: todas,
          postsVisor: postsVisor,
          base: 0,
        ),
      _tituloSeccion(context, 'Fotos publicadas', publicadas.length),
      if (publicadas.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Aún no hay fotos en sus publicaciones.'),
        )
      else
        _grupoGrilla(
          context,
          label: null,
          items: publicadas,
          visorTodos: todas,
          postsVisor: postsVisor,
          base: perfilFotos.length,
        ),
    ];
  }

  List<MultimediaItem> _fotosDe(PublicacionResponse p) {
    final lista = <MultimediaItem>[];
    for (final m in p.multimedia) {
      if (m.tipo == 'imagen') {
        lista.add(m);
      } else if (m.tipo == 'video' && m.poster != null) {
        lista.add((
          url: m.poster!,
          tipo: 'imagen',
          duracion: null,
          poster: null,
        ));
      }
    }
    return lista;
  }

  Widget _grupoGrilla(
    BuildContext context, {
    required String? label,
    required List<MultimediaItem> items,
    required List<MultimediaItem> visorTodos,
    required int base,
    List<PublicacionResponse?>? postsVisor,
    int crossAxisCount = 3,
  }) {
    final visibles = items.take(crossAxisCount * 3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textSecondaryColor(context),
              ),
            ),
          ),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, i) {
            return _fotoMini(
              context,
              visibles[i],
              visorTodos,
              base + i,
              post: postsVisor != null ? postsVisor[base + i] : null,
              extra: (i == visibles.length - 1 && visibles.length < items.length)
                  ? items.length - visibles.length
                  : 0,
            );
          },
        ),
      ],
    );
  }

  Widget _fotoMini(
    BuildContext context,
    MultimediaItem item,
    List<MultimediaItem> visorTodos,
    int indice, {
    PublicacionResponse? post,
    int extra = 0,
  }) {
    final url = resolverUrlMedia(item.url) ?? item.url;
    return InkWell(
      onTap: () =>
          abrirVisorMultimedia(context, visorTodos, indice, post: post),
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: surfaceCard(context),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textHint,
                  size: 16,
                ),
              ),
            ),
            if (extra > 0)
              Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabVideos(BuildContext context, PublicProfileState state) {
    final videos = <MultimediaItem>[
      for (final p in state.publicaciones)
        for (final m in p.multimedia)
          if (m.tipo == 'video') m,
    ];
    final visibles = videos.take(12).toList();

    return [
      _tituloSeccion(context, 'Videos y reels subidos', videos.length),
      if (visibles.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Aún no hay videos en sus publicaciones.'),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, i) => _videoMini(context, videos, i),
          ),
        ),
    ];
  }

  Widget _videoMini(
    BuildContext context,
    List<MultimediaItem> videos,
    int indice,
  ) {
    final item = videos[indice];
    final poster = resolverUrlMedia(item.poster ?? '') ?? item.poster;
    return InkWell(
      onTap: () => abrirVisorMultimedia(context, videos, indice),
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (poster != null)
              Image.network(
                poster,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fondoVideo(context),
              )
            else
              _fondoVideo(context),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            if (item.duracion != null)
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.duracion!,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 8.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fondoVideo(BuildContext context) {
    return Container(
      color: surfaceCard(context),
      alignment: Alignment.center,
      child: const Icon(
        Icons.videocam_off_outlined,
        color: AppColors.textHint,
        size: 18,
      ),
    );
  }

  List<Widget> _tabCompartido(
    BuildContext context,
    PerfilPublicoResponse perfil,
    PublicProfileState state,
  ) {
    final esPropio = perfil.usuarioId == _usuarioIdPropio(context);
    final compartidos = state.publicaciones
        .where((p) =>
            p.esCompartido &&
            p.visibilidad != 'SOLO_YO' &&
            p.compartidoDeId != null)
        .toList();
    final privados = esPropio
        ? state.publicaciones
            .where((p) => p.visibilidad == 'SOLO_YO')
            .toList()
        : const <PublicacionResponse>[];
    final verPrivados = esPropio && _verPrivados;

    return [
      if (esPropio)
        _selectorCompartidoPrivado(
          context,
          compartidos.length,
          privados.length,
        )
      else
        _tituloSeccion(context, 'Compartido', compartidos.length),
      if (!verPrivados) ...[
        if (compartidos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              esPropio
                  ? 'Aún no has recompartido publicaciones de otros perfiles.'
                  : 'Aún no ha recompartido publicaciones de otros perfiles.',
            ),
          )
        else
          ...compartidos.map(
            (p) => PostCard(
              post: p,
              usuarioId: _usuarioIdPropio(context),
            ),
          ),
      ] else ...[
        if (privados.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tus publicaciones "solo para mí" aparecerán aquí.',
            ),
          )
        else
          ...privados.map(
            (p) => PostCard(
              post: p,
              usuarioId: _usuarioIdPropio(context),
            ),
          ),
      ],
    ];
  }

  Widget _selectorCompartidoPrivado(
    BuildContext context,
    int nCompartidos,
    int nPrivados,
  ) {
    final prim = primaryOf(context);
    final sec = textSecondaryColor(context);

    Widget boton(String texto, bool activo, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
            decoration: BoxDecoration(
              color:
                  activo ? prim.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: activo ? prim : sec.withValues(alpha: 0.35),
                width: activo ? 1.4 : 1,
              ),
            ),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: activo ? prim : sec,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          boton(
            'Compartido ($nCompartidos)',
            !_verPrivados,
            () => setState(() => _verPrivados = false),
          ),
          const SizedBox(width: 8),
          boton(
            'Privado (solo para mí) ($nPrivados)',
            _verPrivados,
            () => setState(() => _verPrivados = true),
          ),
        ],
      ),
    );
  }

  List<Widget> _tabMenciones(
    BuildContext context,
    PerfilPublicoResponse perfil,
    PublicProfileState state,
  ) {
    return [
      _seccionCajaMuro(context, perfil),
      _tituloSeccion(
        context,
        'Publicaciones etiquetadas',
        state.menciones.length,
      ),
      if (state.cargandoMenciones)
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        )
      else if (state.menciones.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Todavía no han mencionado a este usuario.'),
        )
      else
        ...state.menciones.take(20).map((p) => _tarjetaMencion(context, p)),
    ];
  }

  Future<void> _publicarEnMuro(BuildContext context) async {
    final contenidoRaw = _muroController.text.trim();
    if (contenidoRaw.isEmpty || _publicandoMuro) return;
    final perfil = context.read<PublicProfileCubit>().state.perfil;
    if (perfil == null) return;

    final contenido = contenidoRaw.startsWith('@')
        ? contenidoRaw
        : '@${perfil.nombreUsuario} $contenidoRaw';

    final community = context.read<CommunityCubit>();
    final profileCubit = context.read<PublicProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _publicandoMuro = true);
    final creada = await community.crearPublicacion(contenido: contenido.trim());
    if (!mounted) return;
    setState(() => _publicandoMuro = false);
    if (creada != null) {
      _muroController.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Publicado en el muro del usuario.')),
      );
      profileCubit.recargarExtras();
    }
  }

  Widget _seccionCajaMuro(BuildContext context, PerfilPublicoResponse perfil) {    return PostCardContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: primaryOf(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Escribir en el muro',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: textColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _muroController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Escríbele un mensaje a @${perfil.nombreUsuario}…',
              filled: true,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed:
                  _publicandoMuro ? null : () => _publicarEnMuro(context),
              icon: _publicandoMuro
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 16),
              label: const Text('Publicar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMencion(BuildContext context, PublicacionResponse post) {
    return InkWell(
      onTap: () => abrirPerfilUsuario(context, post.usuarioId),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              nombre: post.nombreUsuario,
              fotoUrl: post.fotoPerfil,
              radius: 14,
              onTap: () => abrirPerfilUsuario(context, post.usuarioId),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.nombreUsuario,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            color: textColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo(post.fechaPublicacion),
                        style: TextStyle(
                          color: textSecondaryColor(context),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  ExpandableRichText(
                    texto: post.contenido,
                    limite: 70,
                    baseStyle: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: textColor(context),
                    ),
                    onMentionTap: (nombre) => _abrirMencion(context, nombre),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirMencion(BuildContext context, String nombre) async {
    try {
      final resultado =
          await context.read<BusquedaService>().buscar(nombre, limite: 5);
      if (!context.mounted) return;
      final usuarios = resultado.usuarios;
      if (usuarios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No encontramos ese usuario en Eco Retos.'),
          ),
        );
        return;
      }
      final match = usuarios.firstWhere(
        (u) => u.nombreUsuario.toLowerCase() == nombre.toLowerCase(),
        orElse: () => usuarios.first,
      );
      abrirPerfilUsuario(context, match.usuarioId);
    } catch (_) {}
  }

  Widget _seccionCalificaciones(
    BuildContext context,
    PerfilPublicoResponse perfil,
    PublicProfileState state,
  ) {
    final resumen = state.calificaciones;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calificaciones',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: textColor(context),
            ),
          ),
          const SizedBox(height: 10),
          if (state.cargandoCalificaciones)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (resumen == null)
            const SizedBox.shrink()
          else
            _tarjetaCalificaciones(context, perfil, resumen),
        ],
      ),
    );
  }

  Widget _tarjetaCalificaciones(
    BuildContext context,
    PerfilPublicoResponse perfil,
    ResumenCalificaciones resumen,
  ) {
    final sec = textSecondaryColor(context);

    return PostCardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                resumen.total > 0
                    ? resumen.promedio.toStringAsFixed(1)
                    : '—',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: textColor(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filaEstrellas(
                      context,
                      resumen.total > 0 ? resumen.promedio : 0,
                      tamano: 18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resumen.total == 1
                          ? '1 opinión'
                          : '${resumen.total} opiniones',
                      style: TextStyle(color: sec, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!perfil.esMiPerfil) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: dividerColor(context).withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Tu calificación',
                  style: TextStyle(color: sec, fontSize: 13),
                ),
                const Spacer(),
                if (resumen.calificacionPropia != null)
                  TextButton(
                    onPressed: _guardandoCalificacion
                        ? null
                        : () => _quitarCalificacion(),
                    child: const Text('Quitar'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: _guardandoCalificacion
                        ? null
                        : () => _calificarConDialogo(i),
                    icon: Icon(
                      i <=
                              (_calificacionSeleccionada ??
                                  resumen.calificacionPropia ??
                                  0)
                          ? Icons.star
                          : Icons.star_border,
                      color: i <=
                              (_calificacionSeleccionada ??
                                  resumen.calificacionPropia ??
                                  0)
                          ? AppColors.xpGold
                          : sec,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 30, height: 36),
                  ),
              ],
            ),
          ],
          if (resumen.opiniones.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(height: 1, color: dividerColor(context).withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            ...resumen.opiniones.take(5).map((o) => _filaOpinion(context, o)),
          ],
        ],
      ),
    );
  }

  Widget _filaOpinion(BuildContext context, CalificacionOpinion opinion) {
    final sec = textSecondaryColor(context);
    return InkWell(
      onTap: () => abrirPerfilUsuario(context, opinion.usuarioId),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              nombre: opinion.nombreUsuario,
              fotoUrl: opinion.fotoPerfil,
              radius: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          opinion.nombreUsuario,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: textColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _filaEstrellas(context, opinion.calificacion.toDouble(),
                          tamano: 12),
                    ],
                  ),
                  if (opinion.comentario != null &&
                      opinion.comentario!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      opinion.comentario!,
                      style: TextStyle(color: textColor(context), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              fechaCompleta(opinion.fecha),
              style: TextStyle(color: sec, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaEstrellas(BuildContext context, double valor,
      {double tamano = 14}) {
    final completo = valor.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= completo ? Icons.star : Icons.star_border,
            size: tamano,
            color: AppColors.xpGold,
          ),
      ],
    );
  }

Future<void> _calificarConDialogo(int calificacion) async {
    final comentarioController = TextEditingController();
    setState(() => _calificacionSeleccionada = calificacion);
    final titulo = calificacion == 1
        ? 'Calificar con 1 estrella'
        : 'Calificar con $calificacion estrellas';
    try {
      final comentario = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: comentarioController,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: 'Comentario (opcional)',
              hintText: 'Cuéntanos qué te pareció su perfil…',
              filled: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(comentarioController.text.trim()),
              child: const Text('Calificar'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (comentario == null) {
        setState(() => _calificacionSeleccionada = null);
        return;
      }
      setState(() => _guardandoCalificacion = true);
      final ok = await context
          .read<PublicProfileCubit>()
          .calificar(calificacion: calificacion, comentario: comentario);
      if (!mounted) return;
      setState(() {
        _guardandoCalificacion = false;
        _calificacionSeleccionada = null;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calificación guardada. ¡Gracias!')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardandoCalificacion = false;
          _calificacionSeleccionada = null;
        });
      }
    } finally {
      comentarioController.dispose();
    }
  }

  Future<void> _quitarCalificacion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Quitar tu calificación?'),
        content: const Text('Tu calificación se eliminará de este perfil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _guardandoCalificacion = true);
    await context.read<PublicProfileCubit>().eliminarCalificacion();
    if (mounted) setState(() => _guardandoCalificacion = false);
  }

  Widget _stat(BuildContext context, String valor, String label,
      {VoidCallback? onTap}) {
    final contenido = Column(
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
    if (onTap == null) return contenido;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: contenido,
      ),
    );
  }
}

class _ListaUsuariosSheet extends StatefulWidget {
  final String titulo;
  final String vacio;
  final Future<List<UsuarioResumen>> Function() cargar;

  const _ListaUsuariosSheet({
    required this.titulo,
    required this.vacio,
    required this.cargar,
  });

  @override
  State<_ListaUsuariosSheet> createState() => _ListaUsuariosSheetState();
}

class _ListaUsuariosSheetState extends State<_ListaUsuariosSheet> {
  late Future<List<UsuarioResumen>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final sec = textSecondaryColor(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              widget.titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor(context),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UsuarioResumen>>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final usuarios = snapshot.data ?? const <UsuarioResumen>[];
                if (usuarios.isEmpty) {
                  return Center(
                    child: Text(
                      widget.vacio,
                      style: TextStyle(color: sec, fontSize: 13),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: usuarios.length,
                  itemBuilder: (context, i) {
                    final usuario = usuarios[i];
                    return ListTile(
                      leading: UserAvatar(
                        nombre: usuario.nombreUsuario,
                        fotoUrl: usuario.fotoPerfil,
                        radius: 18,
                      ),
                      title: Text(
                        usuario.nombreUsuario,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: textColor(context),
                        ),
                      ),
                      subtitle: Text(
                        usernameSlug(usuario.nombreUsuario),
                        style: TextStyle(color: sec, fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onTap: () => Navigator.of(context).pop(usuario),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
