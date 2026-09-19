import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/firebase_options.dart';
import 'notification_service.dart';

/// Handler de FCM que se ejecuta en un isolate aparte cuando la app está en
/// segundo plano o cerrada. Debe ser de nivel superior.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage mensaje) async {
  if (!FirebaseConfig.disponible) return;
  try {
    await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
  } catch (e) {
    debugPrint('No se pudo inicializar Firebase en segundo plano: $e');
  }
  await NotificationService.instance.init(background: true);
  await NotificationService.instance.mostrarDesdeMensaje(mensaje);
}

/// Servicio de notificaciones push (Firebase Cloud Messaging).
///
/// Si no hay credenciales de Firebase configuradas, el servicio queda inactivo
/// sin afectar al resto de la app (las notificaciones locales siguen
/// funcionando). La app muestra SIEMPRE el sonido `notificacion.mp3` porque
/// las notificaciones locales usan el canal `eco_reto_notificaciones_v1`.
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  static const String _claveToken = 'fcm_token';

  /// Último token FCM conocido (null si FCM no está configurado).
  final ValueNotifier<String?> token = ValueNotifier<String?>(null);

  /// Payload recibido al abrir la app desde una notificación (app cerrada).
  String? payloadInicial;

  bool _inicializado = false;

  /// Callback que la app usa para refrescar la lista de notificaciones.
  VoidCallback? onMensajeRecibido;

  bool get disponible => FirebaseConfig.disponible;

  Future<void> init() async {
    if (_inicializado) return;
    _inicializado = true;

    if (!FirebaseConfig.disponible) {
      debugPrint(
        'FCM desactivado: configura FIREBASE_API_KEY, FIREBASE_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID y FIREBASE_PROJECT_ID.',
      );
      return;
    }

    try {
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
    } catch (e) {
      debugPrint('No se pudo inicializar Firebase: $e');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      // En iOS el permiso se pide aquí; en Android lo pide la pantalla de
      // permisos obligatorios (permission_handler) para no duplicar diálogos.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Los listeners se registran ANTES de pedir el token para no perder
      // mensajes si el token tarda o falla (por ejemplo en emuladores).
      FirebaseMessaging.onMessage.listen((mensaje) async {
        await NotificationService.instance.mostrarDesdeMensaje(
          mensaje,
          primerPlano: true,
        );
        onMensajeRecibido?.call();
      });

      FirebaseMessaging.onMessageOpenedApp.listen((mensaje) {
        final payload = _payloadDe(mensaje);
        if (payload != null) {
          NotificationService.instance.emitirApertura(payload);
        }
      });

      try {
        await _guardarToken(await messaging.getToken());
        messaging.onTokenRefresh.listen(_guardarToken);
      } catch (e) {
        debugPrint('No se pudo obtener el token FCM: $e');
      }

      // App cerrada abierta desde una notificación: se guarda el payload para
      // navegar a Notificaciones cuando haya sesión.
      try {
        final inicial = await messaging.getInitialMessage();
        if (inicial != null) {
          payloadInicial = _payloadDe(inicial);
          // Si la sesión ya está iniciada, la app navegará con este aviso.
          if (payloadInicial != null && payloadInicial!.isNotEmpty) {
            NotificationService.instance.emitirApertura(payloadInicial!);
          }
        }
      } catch (_) {
        // Sin mensaje inicial.
      }

      debugPrint('FCM listo. Token: ${token.value}');
    } catch (e) {
      debugPrint('FCM no disponible: $e');
    }
  }

  String? _payloadDe(RemoteMessage mensaje) {
    final data = mensaje.data;
    final payload = data['payload'] ?? data['referencia'] ?? data['tipo'];
    return payload?.toString();
  }

  Future<void> _guardarToken(String? nuevoToken) async {
    if (nuevoToken == null || nuevoToken.isEmpty) return;
    token.value = nuevoToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveToken, nuevoToken);
    } catch (_) {
      // Si no se puede persistir, el token sigue disponible en memoria.
    }
  }

  /// Token guardado en el dispositivo (útil para enviarlo al backend).
  Future<String?> tokenGuardado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_claveToken);
    } catch (_) {
      return null;
    }
  }
}
