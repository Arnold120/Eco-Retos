import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../community/post_detail_screen.dart';
import '../community/user_profile_screen.dart';
import '../messages/conversation_screen.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as eco;
import '../widgets/loading_widget.dart';
import 'cubit/notification_cubit.dart';




class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().loadNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: const MuroNotificacionesView(),
    );
  }
}


class MuroNotificacionesView extends StatefulWidget {
  final void Function(int publicacionId)? onAbrirPublicacion;
  final void Function(int usuarioId)? onAbrirPerfil;
  final void Function(int conversacionId)? onAbrirConversacion;

  const MuroNotificacionesView({
    super.key,
    this.onAbrirPublicacion,
    this.onAbrirPerfil,
    this.onAbrirConversacion,
  });

  @override
  State<MuroNotificacionesView> createState() =>
      _MuroNotificacionesViewState();
}

class _MuroNotificacionesViewState extends State<MuroNotificacionesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().loadNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (state.isLoading && state.notificaciones.isEmpty) {
          return _buildSkeleton(isDark);
        }

        if (state.error != null && state.notificaciones.isEmpty) {
          return eco.ErrorWidget(
            message: state.error!,
            actionLabel: 'Reintentar',
            onAction: () =>
                context.read<NotificationCubit>().loadNotificaciones(),
          );
        }

        return Column(
          children: [
            _barraAcciones(context, state),
            Expanded(
              child: state.notificaciones.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.notifications_none,
                      title: 'No tienes notificaciones',
                      subtitle: 'Las aparecerán aquí cuando las tengas',
                      actionLabel: 'Actualizar',
                      onAction: () => context
                          .read<NotificationCubit>()
                          .loadNotificaciones(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context
                          .read<NotificationCubit>()
                          .loadNotificaciones(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.notificaciones.length,
                        itemBuilder: (context, index) {
                          final notif = state.notificaciones[index];
                          return _buildNotificationTile(notif, state, isDark);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _barraAcciones(BuildContext context, NotificationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          const Text(
            'Notificaciones',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(width: 8),
          if (state.noLeidas > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error, AppColors.warning],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.noLeidas} sin leer',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 11.5,
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () =>
                context.read<NotificationCubit>().loadNotificaciones(),
            icon: const Icon(Icons.refresh, size: 20),
          ),
          if (state.notificaciones.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    context.read<NotificationCubit>().marcarTodasLeidas();
                    break;
                  case 'clear_all':
                    _showClearAllDialog(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 8),
                      Text('Marcar todas como leídas'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar todas'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => _buildNotificationSkeleton(isDark),
    );
  }

  Widget _buildNotificationSkeleton(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColorsDark.border : AppColors.border)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          SkeletonWidgets.shimmerCircle(44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidgets.shimmerRect(width: 140, height: 18),
                const SizedBox(height: 4),
                SkeletonWidgets.shimmerRect(width: 200, height: 14),
                const SizedBox(height: 4),
                SkeletonWidgets.shimmerRect(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificacionResponse notif,
    NotificationState state,
    bool isDark,
  ) {
    final color = _getNotificationColor(notif.tipo);
    final isUnread = !notif.leida;

    return Dismissible(
      key: ValueKey(notif.notificacionId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: AppColors.error, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirm(context);
      },
      onDismissed: (_) {
        context.read<NotificationCubit>().eliminar(notif.notificacionId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05)
              : (isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.3)
                : (isDark ? AppColorsDark.border : AppColors.border)
                    .withValues(alpha: 0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _abrirDestino(context, notif, isUnread),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUnread
                            ? [
                                color.withValues(alpha: 0.3),
                                color.withValues(alpha: 0.1),
                              ]
                            : [
                                (isDark
                                    ? AppColorsDark.surfaceDim
                                    : AppColors.surfaceDim)
                                        .withValues(alpha: 0.5),
                                (isDark
                                    ? AppColorsDark.surfaceDim
                                    : AppColors.surfaceDim)
                                        .withValues(alpha: 0.3),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getNotifIcon(notif.tipo),
                      color: isUnread ? color : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notif.titulo,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      isUnread ? FontWeight.w700 : FontWeight.w500,
                                  color: isDark
                                      ? AppColorsDark.textPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.mensaje,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 11,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(notif.fecha),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTipoLabel(notif.tipo),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirDestino(
    BuildContext context,
    NotificacionResponse notif,
    bool isUnread,
  ) async {
    if (isUnread) {
      context.read<NotificationCubit>().marcarLeida(notif.notificacionId);
    }

    final auth = context.read<AuthCubit>().state;
    final usuarioId = auth is Authenticated ? auth.usuarioId : 0;
    final tipo = (notif.referenciaTipo ?? '').toUpperCase();
    final referenciaId = notif.referenciaId;

    switch (tipo) {
      case 'PUBLICACION':
      case 'COMENTARIO':
        if (referenciaId != null) {
          if (widget.onAbrirPublicacion != null) {
            widget.onAbrirPublicacion!(referenciaId);
          } else {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(publicacionId: referenciaId),
              ),
            );
          }
        }
        break;
      case 'USUARIO':
        final objetivo = notif.actorUsuarioId ?? referenciaId;
        if (objetivo != null) {
          if (widget.onAbrirPerfil != null) {
            widget.onAbrirPerfil!(objetivo);
          } else {
            abrirPerfilUsuario(context, objetivo);
          }
        }
        break;
      case 'CONVERSACION':
        if (referenciaId != null) {
          if (widget.onAbrirConversacion != null) {
            widget.onAbrirConversacion!(referenciaId);
          } else {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConversationScreen(
                  conversacionId: referenciaId,
                  usuarioId: usuarioId,
                  titulo: 'Conversación',
                ),
              ),
            );
          }
        }
        break;
      default:
        break;
    }
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar notificación?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar todas las notificaciones?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<NotificationCubit>().eliminarTodas();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones eliminadas')),
              );
            },
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Hace ${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getNotifIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RETO':
        return Icons.emoji_events;
      case 'TRIVIA':
        return Icons.quiz;
      case 'LOGRO':
        return Icons.workspace_premium;
      case 'NIVEL':
        return Icons.military_tech;
      case 'JARDIN':
        return Icons.park;
      case 'SISTEMA':
        return Icons.info;
      case 'COMUNIDAD':
        return Icons.people;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RETO':
        return AppColors.primary;
      case 'TRIVIA':
        return AppColors.info;
      case 'LOGRO':
        return AppColors.xpGold;
      case 'NIVEL':
        return AppColors.levelPurple;
      case 'JARDIN':
        return AppColors.gardenGreen;
      case 'SISTEMA':
        return AppColors.warning;
      case 'COMUNIDAD':
        return AppColors.coralSoft;
      default:
        return AppColors.primary;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RETO':
        return 'Reto';
      case 'TRIVIA':
        return 'Trivia';
      case 'LOGRO':
        return 'Logro';
      case 'NIVEL':
        return 'Nivel';
      case 'JARDIN':
        return 'Jardín';
      case 'SISTEMA':
        return 'Sistema';
      case 'COMUNIDAD':
        return 'Comunidad';
      default:
        return 'General';
    }
  }
}
