import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../messages/cubit/messages_cubit.dart';
import '../messages/conversation_screen.dart';
import '../messages/messages_screen.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../notifications/notification_screen.dart';
import '../search/search_screen.dart';
import '../widgets/user_avatar.dart';
import 'create_post_screen.dart';
import 'cubit/community_cubit.dart';
import 'cubit/community_state.dart';
import 'muro_perfil_view.dart';
import 'post_detail_screen.dart';
import 'user_profile_screen.dart';
import 'usuarios_screen.dart';
import 'widgets/post_card.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/post_helpers.dart';



enum _SeccionMuro { inicio, usuarios, mensajes, alertas, guardados, perfil }

class CommunityScreen extends StatefulWidget {
  final int usuarioId;
  final String nombreUsuario;
  final VoidCallback? onMenuTap;

  const CommunityScreen({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
    this.onMenuTap,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _scroll = ScrollController();
  late final CommunityCubit _cubit;

  _SeccionMuro _seccion = _SeccionMuro.inicio;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _cubit = context.read<CommunityCubit>();
    _cubit.detenerSondeo();
    _cubit.iniciarSondeo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.refrescarSilencioso();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _cubit.detenerSondeo();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      context.read<CommunityCubit>().cargarMas();
    }
  }

  Future<void> _abrirCompositor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _cubit,
          child: CreatePostScreen(usuarioId: widget.usuarioId),
        ),
      ),
    );
  }



  Future<void> _irA(_SeccionMuro seccion) async {
    switch (seccion) {
      case _SeccionMuro.inicio:
        setState(() {
          _seccion = _SeccionMuro.inicio;
        });

        if (_cubit.state.filtro != MuroFiltro.paraTi) {
          await _cubit.cambiarFiltro(MuroFiltro.paraTi);
        } else {
          await _cubit.refresh();
        }
        _irAlPrincipio();
        break;
      case _SeccionMuro.guardados:
        setState(() {
          _seccion = _SeccionMuro.guardados;
        });
        if (_cubit.state.filtro != MuroFiltro.guardadas) {
          await _cubit.cambiarFiltro(MuroFiltro.guardadas);
        } else {
          await _cubit.refresh();
        }
        _irAlPrincipio();
        break;
      case _SeccionMuro.mensajes:
        setState(() {
          _seccion = _SeccionMuro.mensajes;
        });
        context.read<MessagesCubit>().load();
        break;
      case _SeccionMuro.alertas:
        setState(() {
          _seccion = _SeccionMuro.alertas;
        });
        context.read<NotificationCubit>().loadNotificaciones();
        break;
      case _SeccionMuro.usuarios:
      case _SeccionMuro.perfil:
        setState(() {
          _seccion = seccion;
        });
        break;
    }
  }

  void _irAlPrincipio() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  void _abrirConversacionPorId(
    int conversacionId, {
    String titulo = 'Conversación',
    String? fotoUrl,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          conversacionId: conversacionId,
          usuarioId: widget.usuarioId,
          titulo: titulo,
          fotoUrl: fotoUrl,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enFeed = _seccion == _SeccionMuro.inicio ||
        _seccion == _SeccionMuro.guardados;

    return BlocListener<CommunityCubit, CommunityState>(
      listenWhen: (a, b) =>
          (b.error != null && b.error != a.error) ||
          (b.mensajeExito != null && b.mensajeExito != a.mensajeExito),
      listener: (context, state) {
        final mensaje = state.error ?? state.mensajeExito;
        if (mensaje == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: state.error != null ? AppColors.error : null,
          ),
        );
        context.read<CommunityCubit>().limpiarMensajes();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColorsDark.background : AppColors.background,
        floatingActionButton: enFeed
            ? FloatingActionButton.extended(
                onPressed: _abrirCompositor,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Publicar'),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              _barraBusqueda(context, isDark),
              _titulo(context),
              Divider(
                height: 1,
                color: dividerColor(context).withValues(alpha: 0.5),
              ),
              _navegacionMuro(context),
              Expanded(child: _cuerpo(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cuerpo(BuildContext context) {
    switch (_seccion) {
      case _SeccionMuro.inicio:
      case _SeccionMuro.guardados:
        return BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            return AnchoLectura(
              child: RefreshIndicator(
                onRefresh: () => context.read<CommunityCubit>().refresh(),
                child: _feed(context, state),
              ),
            );
          },
        );
      case _SeccionMuro.usuarios:
        return MuroUsuariosView(usuarioId: widget.usuarioId);
      case _SeccionMuro.mensajes:
        return MuroMensajesView(
          usuarioId: widget.usuarioId,
          onAbrir: (c) => _abrirConversacionPorId(
            c.conversacionId,
            titulo: c.otroNombreUsuario,
            fotoUrl: c.otroFotoPerfil,
          ),
        );
      case _SeccionMuro.alertas:
        return MuroNotificacionesView(
          onAbrirPublicacion: (id) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(publicacionId: id),
            ),
          ),
          onAbrirPerfil: (id) => abrirPerfilUsuario(context, id),
          onAbrirConversacion: (id) => _abrirConversacionPorId(id),
        );
      case _SeccionMuro.perfil:
        return MuroPerfilView(usuarioId: widget.usuarioId);
    }
  }



  Widget _barraBusqueda(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 12, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menú',
            onPressed: widget.onMenuTap,
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColorsDark.surfaceDim
                      : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, size: 20, color: AppColors.textHint),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buscar en Eco Retos…',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ecoreto_logo.png',
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.eco,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muro Eco',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor(context),
                  ),
                ),
                Text(
                  'Comparte y descubre acciones por el planeta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: textSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navegacionMuro(BuildContext context) {
    final mensajesNoLeidos =
        context.watch<MessagesCubit>().state.totalNoLeidos;
    final alertasNoLeidas = context.watch<NotificationCubit>().state.noLeidas;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          _NavMuro(
            icono: Icons.home_outlined,
            label: 'Inicio',
            activo: _seccion == _SeccionMuro.inicio,
            onTap: () => _irA(_SeccionMuro.inicio),
          ),
          _NavMuro(
            icono: Icons.people_alt_outlined,
            label: 'Usuarios',
            activo: _seccion == _SeccionMuro.usuarios,
            onTap: () => _irA(_SeccionMuro.usuarios),
          ),
          _NavMuro(
            icono: Icons.mail_outline,
            label: 'Mensajes',
            badge: mensajesNoLeidos,
            activo: _seccion == _SeccionMuro.mensajes,
            onTap: () => _irA(_SeccionMuro.mensajes),
          ),
          _NavMuro(
            icono: Icons.notifications_none,
            label: 'Alertas',
            badge: alertasNoLeidas,
            activo: _seccion == _SeccionMuro.alertas,
            onTap: () => _irA(_SeccionMuro.alertas),
          ),
          _NavMuro(
            icono: _seccion == _SeccionMuro.guardados
                ? Icons.bookmark
                : Icons.bookmark_outline,
            label: 'Guardados',
            activo: _seccion == _SeccionMuro.guardados,
            onTap: () => _irA(_SeccionMuro.guardados),
          ),
          _NavMuro(
            icono: Icons.person_outline,
            label: 'Perfil',
            activo: _seccion == _SeccionMuro.perfil,
            onTap: () => _irA(_SeccionMuro.perfil),
          ),
        ],
      ),
    );
  }



  Widget _feed(BuildContext context, CommunityState state) {
    if (state.cargandoInicial) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          PostCardSkeleton(),
          PostCardSkeleton(),
          PostCardSkeleton(),
        ],
      );
    }

    if (state.error != null && state.publicaciones.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: SocialErrorState(
              mensaje: state.error!,
              onReintentar: () =>
                  context.read<CommunityCubit>().loadPublicaciones(),
            ),
          ),
        ],
      );
    }

    final feed = state.feed;

    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: _conteoItems(state, feed),
      itemBuilder: (context, i) {
        if (i == 0) {
          return _entradaCompositor(context);
        }

        final index = i - 1;

        if (feed.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _vacio(context, state),
          );
        }

        if (index >= feed.length) {
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return const SizedBox(height: 16);
        }

        return PostCard(
          key: ValueKey(feed[index].publicacionId),
          post: feed[index],
          usuarioId: widget.usuarioId,
        );
      },
    );
  }

  int _conteoItems(CommunityState state, List feed) {
    if (feed.isEmpty) return 2;
    final cargando = state.isLoadingMore ? 1 : 0;
    return feed.length + 1 + cargando;
  }

  Widget _entradaCompositor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Material(
        color: surfaceCard(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _abrirCompositor,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CurrentUserAvatar(radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Qué acción ambiental compartes hoy?',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.photo_outlined,
                    color: textSecondaryColor(context), size: 20),
                const SizedBox(width: 10),
                Icon(Icons.videocam_outlined,
                    color: textSecondaryColor(context), size: 20),
                const SizedBox(width: 10),
                Icon(Icons.edit_outlined,
                    color: textSecondaryColor(context), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vacio(BuildContext context, CommunityState state) {
    switch (state.filtro) {
      case MuroFiltro.siguiendo:
        return const SocialEmptyState(
          icono: Icons.people_outline,
          titulo: 'Aún no sigues a nadie',
          subtitulo:
              'Sigue a otros eco-héroes para ver sus publicaciones aquí.',
        );
      case MuroFiltro.misPublicaciones:
        return SocialEmptyState(
          icono: Icons.edit_note,
          titulo: 'No tienes publicaciones',
          subtitulo: 'Comparte tu primera acción ambiental y motiva a otros.',
          accionLabel: 'Crear publicación',
          onAccion: _abrirCompositor,
        );
      case MuroFiltro.guardadas:
        return const SocialEmptyState(
          icono: Icons.bookmark_outline,
          titulo: 'Sin publicaciones guardadas',
          subtitulo:
              'Usa el botón Guardar en una publicación para verla aquí.',
        );
      case MuroFiltro.cercaDeTi:
        return const SocialEmptyState(
          icono: Icons.place_outlined,
          titulo: 'No hay iniciativas cerca de ti',
          subtitulo:
              'Crea una publicación con ubicación para convocar a tu comunidad.',
        );
      default:
        return SocialEmptyState(
          icono: Icons.eco_outlined,
          titulo: 'Todavía no hay publicaciones',
          subtitulo:
              'Sé la primera persona en compartir una acción ambiental.',
          accionLabel: 'Crear publicación',
          onAccion: _abrirCompositor,
        );
    }
  }
}


class _NavMuro extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final int badge;
  final bool activo;

  const _NavMuro({
    required this.icono,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.activo = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? primaryOf(context) : textSecondaryColor(context);

    Widget iconoWidget = Icon(icono, size: 22, color: color);
    if (badge > 0) {
      iconoWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconoWidget,
          Positioned(
            right: -7,
            top: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 15),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Expanded(
      child: Semantics(
        button: true,
        selected: activo,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconoWidget,
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
