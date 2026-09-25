import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/firebase_options.dart';
import 'notification_service.dart';



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







class PushService {
  PushService._();

  static final PushService instance = PushService._();

  static const String _claveToken = 'fcm_token';


  final ValueNotifier<String?> token = ValueNotifier<String?>(null);


  String? payloadInicial;

  bool _inicializado = false;


  VoidCallback? onMensajeRecibido;
  VoidCallback? onTokenActualizado;

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



      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }



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



      try {
        final inicial = await messaging.getInitialMessage();
        if (inicial != null) {
          payloadInicial = _payloadDe(inicial);

          if (payloadInicial != null && payloadInicial!.isNotEmpty) {
            NotificationService.instance.emitirApertura(payloadInicial!);
          }
        }
      } catch (_) {

      }

      debugPrint('FCM listo. Token: ${token.value}');
    } catch (e) {
      debugPrint('FCM no disponible: $e');
    }
  }

  String? _payloadDe(RemoteMessage mensaje) {
    final data = mensaje.data;
    final payload = data['payload'];
    if (payload != null && payload.toString().isNotEmpty) {
      return payload.toString();
    }
    if (data.isEmpty) return null;
    return jsonEncode(data);
  }

  Future<void> _guardarToken(String? nuevoToken) async {
    if (nuevoToken == null || nuevoToken.isEmpty) return;
    token.value = nuevoToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveToken, nuevoToken);
    } catch (_) {

    }
    onTokenActualizado?.call();
  }


  Future<String?> tokenGuardado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_claveToken);
    } catch (_) {
      return null;
    }
  }
}
