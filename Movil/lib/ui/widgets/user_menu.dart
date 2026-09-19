import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import 'user_avatar.dart';

/// Menu de usuario accesible desde el header: Mi perfil, Mensajes,
/// Notificaciones, Búsqueda, Configuración y Cerrar sesión.
Future<void> showUserMenu(
  BuildContext context, {
  required VoidCallback onMiPerfil,
  required VoidCallback onMensajes,
  required VoidCallback onNotificaciones,
  required VoidCallback onBuscar,
  required VoidCallback onConfiguracion,
  required VoidCallback onPrivacidad,
  required VoidCallback onCerrarSesion,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.surface
        : AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final sec = Theme.of(ctx).brightness == Brightness.dark
          ? AppColorsDark.textSecondary
          : AppColors.textSecondary;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const CurrentUserAvatar(radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final nombre = state is Authenticated
                            ? state.nombreUsuario
                            : 'Eco Héroe';
                        final correo =
                            state is Authenticated ? state.correo : '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            if (correo.isNotEmpty)
                              Text(
                                correo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: sec, fontSize: 12),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _Opcion(
              icono: Icons.person_outline,
              label: 'Mi perfil',
              onTap: () {
                Navigator.of(ctx).pop();
                onMiPerfil();
              },
            ),
            _Opcion(
              icono: Icons.mail_outline,
              label: 'Mensajes',
              onTap: () {
                Navigator.of(ctx).pop();
                onMensajes();
              },
            ),
            _Opcion(
              icono: Icons.notifications_none,
              label: 'Notificaciones',
              onTap: () {
                Navigator.of(ctx).pop();
                onNotificaciones();
              },
            ),
            _Opcion(
              icono: Icons.search,
              label: 'Buscar',
              onTap: () {
                Navigator.of(ctx).pop();
                onBuscar();
              },
            ),
            _Opcion(
              icono: Icons.settings_outlined,
              label: 'Configuración',
              onTap: () {
                Navigator.of(ctx).pop();
                onConfiguracion();
              },
            ),
            _Opcion(
              icono: Icons.privacy_tip_outlined,
              label: 'Privacidad',
              onTap: () {
                Navigator.of(ctx).pop();
                onPrivacidad();
              },
            ),
            const Divider(height: 1),
            _Opcion(
              icono: Icons.logout,
              label: 'Cerrar sesión',
              color: AppColors.error,
              onTap: () {
                Navigator.of(ctx).pop();
                onCerrarSesion();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _Opcion({
    required this.icono,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

/// Confirma el cierre de sesión antes de ejecutarlo.
Future<void> confirmarCerrarSesion(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Cerrar sesión?'),
      content: const Text('Tu progreso está guardado en la nube.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
  if (confirmado == true && context.mounted) {
    context.read<AuthCubit>().logout();
  }
}


