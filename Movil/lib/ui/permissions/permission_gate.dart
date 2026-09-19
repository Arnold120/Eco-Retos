import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';
import 'permission_screen.dart';

/// Bloquea la app hasta que el usuario conceda todos los permisos
/// obligatorios (notificaciones, fotos, videos y almacenamiento según la
/// versión de Android). Vuelve a comprobar al regresar de la configuración.
class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with WidgetsBindingObserver {
  bool _comprobando = true;
  bool _solicitando = false;
  List<PermisoRequerido> _faltantes = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _solicitarYComprobar();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver de la configuración de Android se comprueba de nuevo.
    if (state == AppLifecycleState.resumed && !_comprobando && !_solicitando) {
      _soloComprobar();
    }
  }

  bool _concedido(PermissionStatus estado) =>
      estado.isGranted || estado.isLimited;

  /// Versión de Android (API level). Si no se puede leer, se asume 33 o más
  /// para no pedir `storage`, que está obsoleto desde Android 13.
  Future<int> _androidSdk() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return 0;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (_) {
      return 33;
    }
  }

  /// Permisos obligatorios según la plataforma y la versión de Android.
  ///
  /// En Android 13+ se usan READ_MEDIA_IMAGES/READ_MEDIA_VIDEO mediante
  /// `photos`/`videos`. En Android 12 y anteriores esas dos no existen como
  /// permiso de runtime, así que se solicita `storage`
  /// (READ_EXTERNAL_STORAGE/WRITE_EXTERNAL_STORAGE).
  Future<List<PermisoRequerido>> _requeridos() async {
    final lista = <PermisoRequerido>[];
    if (kIsWeb) return lista;

    if (Platform.isAndroid) {
      final sdk = await _androidSdk();
      lista.add(permisoNotificaciones);
      if (sdk >= 33) {
        lista.add(permisoFotos);
        lista.add(permisoVideos);
      } else {
        lista.add(permisoAlmacenamiento);
      }
      return lista;
    }

    if (Platform.isIOS) {
      lista.add(permisoNotificaciones);
      lista.add(permisoFotos);
      lista.add(permisoVideos);
    }
    return lista;
  }

  /// Estado del permiso sin riesgo de excepción ni espera infinita.
  Future<PermissionStatus> _estadoSeguro(PermisoRequerido requerido) async {
    try {
      return await requerido.permiso.status.timeout(
        const Duration(seconds: 8),
        onTimeout: () => PermissionStatus.denied,
      );
    } catch (e) {
      debugPrint('No se pudo leer el permiso ${requerido.clave}: $e');
      return PermissionStatus.denied;
    }
  }

  /// Solicitud sin riesgo de excepción ni espera infinita.
  Future<PermissionStatus> _solicitarSeguro(PermisoRequerido requerido) async {
    try {
      return await requerido.permiso.request().timeout(
        const Duration(seconds: 90),
        onTimeout: () => PermissionStatus.denied,
      );
    } catch (e) {
      debugPrint('No se pudo solicitar el permiso ${requerido.clave}: $e');
      return PermissionStatus.denied;
    }
  }

  /// Pide los permisos que falten y guarda la lista de los pendientes.
  /// Siempre termina de comprobar, aunque un permiso falle.
  Future<void> _solicitarYComprobar() async {
    if (_solicitando) return;
    _solicitando = true;
    if (mounted) setState(() => _comprobando = true);

    var faltantes = <PermisoRequerido>[];
    try {
      final requeridos = await _requeridos();
      for (final requerido in requeridos) {
        var estado = await _estadoSeguro(requerido);
        if (!_concedido(estado)) {
          estado = await _solicitarSeguro(requerido);
        }
        if (!_concedido(estado)) faltantes.add(requerido);
      }
    } catch (e) {
      debugPrint('Error comprobando permisos: $e');
    } finally {
      _solicitando = false;
      if (mounted) {
        setState(() {
          _faltantes = faltantes;
          _comprobando = false;
        });
      }
    }
  }

  /// Solo comprueba (sin volver a pedir), para cuando el usuario regresa de
  /// la configuración del sistema.
  Future<void> _soloComprobar() async {
    var faltantes = <PermisoRequerido>[];
    try {
      final requeridos = await _requeridos();
      for (final requerido in requeridos) {
        final estado = await _estadoSeguro(requerido);
        if (!_concedido(estado)) faltantes.add(requerido);
      }
    } catch (e) {
      debugPrint('Error comprobando permisos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _faltantes = faltantes;
          _comprobando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_comprobando) return const _PantallaComprobando();
    if (_faltantes.isNotEmpty) {
      return PermissionScreen(
        faltantes: _faltantes,
        onSolicitar: _solicitarYComprobar,
        onAbrirAjustes: () async {
          await openAppSettings();
        },
        onComprobar: _soloComprobar,
      );
    }
    return widget.child;
  }
}

class _PantallaComprobando extends StatelessWidget {
  const _PantallaComprobando();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.background : AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Comprobando permisos…',
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
