import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';


class PermisoRequerido {
  final String clave;
  final Permission permiso;
  final String titulo;
  final String descripcion;
  final IconData icono;

  const PermisoRequerido({
    required this.clave,
    required this.permiso,
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });
}





const PermisoRequerido permisoNotificaciones = PermisoRequerido(
  clave: 'notificaciones',
  permiso: Permission.notification,
  titulo: 'Notificaciones',
  descripcion:
      'Necesario para avisarte de retos, mensajes, logros y respuestas del soporte, aunque la app esté cerrada.',
  icono: Icons.notifications_active_outlined,
);

const PermisoRequerido permisoFotos = PermisoRequerido(
  clave: 'fotos',
  permiso: Permission.photos,
  titulo: 'Fotos',
  descripcion:
      'Necesario para adjuntar la fotografía de evidencia de tus retos y publicar imágenes en la comunidad.',
  icono: Icons.photo_library_outlined,
);

const PermisoRequerido permisoVideos = PermisoRequerido(
  clave: 'videos',
  permiso: Permission.videos,
  titulo: 'Videos',
  descripcion:
      'Necesario para adjuntar videos como evidencia de retos y compartirlos en el muro.',
  icono: Icons.videocam_outlined,
);

const PermisoRequerido permisoAlmacenamiento = PermisoRequerido(
  clave: 'almacenamiento',
  permiso: Permission.storage,
  titulo: 'Almacenamiento',
  descripcion:
      'Necesario para descargar imágenes y videos de los retos en versiones antiguas de Android.',
  icono: Icons.folder_outlined,
);



class PermissionScreen extends StatelessWidget {
  final List<PermisoRequerido> faltantes;
  final Future<void> Function() onSolicitar;
  final Future<void> Function() onAbrirAjustes;
  final Future<void> Function() onComprobar;

  const PermissionScreen({
    super.key,
    required this.faltantes,
    required this.onSolicitar,
    required this.onAbrirAjustes,
    required this.onComprobar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.background : AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Permisos necesarios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColorsDark.textPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Para entrar a Eco-Retos debes conceder los siguientes permisos. '
                    'Sin ellos no es posible mostrarte el contenido ni enviar tus evidencias.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...faltantes.map(
                    (permiso) => _tarjetaPermiso(
                      context,
                      permiso,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => onSolicitar(),
                    icon: const Icon(Icons.verified_user_outlined, size: 20),
                    label: const Text('Conceder permisos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => onAbrirAjustes(),
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    label: const Text('Abrir configuración de la app'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => onComprobar(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Ya los concedí, volver a comprobar'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si algún permiso fue denegado permanentemente, Android no '
                    'volverá a preguntar: actívalo desde la configuración de la app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColorsDark.textHint
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaPermiso(
    BuildContext context,
    PermisoRequerido permiso,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceCard : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? AppColorsDark.border : AppColors.border)
              .withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(permiso.icono, size: 22, color: AppColors.error),
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
                        permiso.titulo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pendiente',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  permiso.descripcion,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
