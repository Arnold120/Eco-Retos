import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/main_shell.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../messages/messages_screen.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../notifications/notification_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import 'user_avatar.dart';
import 'user_menu.dart';

/// Acciones globales del header: busqueda y menu de usuario.
/// Mensajes y notificaciones viven en la barra de navegacion principal,
/// por eso no se duplican aqui.
class GlobalHeaderActions extends StatelessWidget {
  const GlobalHeaderActions({super.key});

  int _usuarioId(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    return state is Authenticated ? state.usuarioId : 0;
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = _usuarioId(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Buscar',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          icon: const Icon(Icons.search),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CurrentUserAvatar(
            radius: 16,
            onTap: () => _abrirMenu(context, usuarioId),
          ),
        ),
      ],
    );
  }

  void _abrirMenu(BuildContext context, int usuarioId) {
    final scope = MainShellScope.maybeOf(context);
    showUserMenu(
      context,
      onMiPerfil: () => scope?.irATab(4),
      onMensajes: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MessagesScreen(usuarioId: usuarioId),
        ),
      ),
      onNotificaciones: () {
        context.read<NotificationCubit>().loadNotificaciones();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      },
      onBuscar: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      onConfiguracion: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsScreen(usuarioId: usuarioId),
        ),
      ),
      onPrivacidad: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsScreen(usuarioId: usuarioId),
        ),
      ),
      onCerrarSesion: () => confirmarCerrarSesion(context),
    );
  }
}
