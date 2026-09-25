import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



const String kCanalNotificacionesId = 'eco_reto_notificaciones_v1';
const String kCanalNotificacionesNombre = 'Notificaciones Eco-Retos';
const String kCanalNotificacionesDescripcion =
    'Avisos de retos, comunidad, mensajes y soporte con el sonido de la app.';
const String kSonidoNotificacion = 'notificacion';




class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _aperturas =
      StreamController<String>.broadcast();


  Stream<String> get aperturas => _aperturas.stream;


  void emitirApertura(String payload) {
    if (payload.isNotEmpty) _aperturas.add(payload);
  }

  bool _inicializado = false;
  int _contador = 0;


  String? payloadInicial;

  AndroidNotificationChannel get _canal => const AndroidNotificationChannel(
        kCanalNotificacionesId,
        kCanalNotificacionesNombre,
        description: kCanalNotificacionesDescripcion,
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(kSonidoNotificacion),
        enableVibration: true,
        showBadge: true,
      );

  AndroidNotificationDetails get _detalleAndroid =>
      const AndroidNotificationDetails(
        kCanalNotificacionesId,
        kCanalNotificacionesNombre,
        channelDescription: kCanalNotificacionesDescripcion,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(kSonidoNotificacion),
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        ticker: 'Eco-Retos',
      );



  Future<void> init({bool background = false}) async {
    if (_inicializado) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (respuesta) {
        if (respuesta.payload != null && respuesta.payload!.isNotEmpty) {
          _aperturas.add(respuesta.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: _respuestaEnSegundoPlano,
    );

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_canal);
    }



    try {
      final detalles = await _plugin.getNotificationAppLaunchDetails();
      final payload = detalles?.notificationResponse?.payload;
      if (detalles?.didNotificationLaunchApp == true &&
          payload != null &&
          payload.isNotEmpty) {
        payloadInicial = payload;
      }
    } catch (_) {

    }

    _inicializado = true;
    if (background) {
      debugPrint('NotificationService inicializado en segundo plano.');
    }
  }


  Future<void> mostrar({
    required String titulo,
    required String cuerpo,
    String? payload,
    int? id,
  }) async {
    await init();
    final detalles = NotificationDetails(
      android: _detalleAndroid,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: '$kSonidoNotificacion.mp3',
      ),
    );

    _contador += 1;
    await _plugin.show(
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000) + _contador,
      titulo,
      cuerpo,
      detalles,
      payload: payload,
    );
  }










  Future<void> mostrarDesdeMensaje(
    RemoteMessage mensaje, {
    bool primerPlano = false,
  }) async {
    final data = mensaje.data;
    final titulo = (mensaje.notification?.title ??
            data['titulo'] ??
            data['title'] ??
            'Eco-Retos')
        .toString();
    final cuerpo = (mensaje.notification?.body ??
            data['cuerpo'] ??
            data['body'] ??
            data['mensaje'] ??
            '')
        .toString();

    final tieneBloqueNotification = mensaje.notification != null;
    if (tieneBloqueNotification && !primerPlano) {

      return;
    }

    if (cuerpo.isEmpty && titulo == 'Eco-Retos') return;

    await mostrar(
      titulo: titulo,
      cuerpo: cuerpo,
      payload: data['payload']?.toString() ??
          (data.isEmpty ? null : jsonEncode(data)),
    );
  }



  Future<bool> solicitarPermisoAndroid() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.requestNotificationsPermission() ?? true;
  }


  Future<void> cancelarTodas() => _plugin.cancelAll();
}



@pragma('vm:entry-point')
void _respuestaEnSegundoPlano(NotificationResponse respuesta) {

  debugPrint(
    'Notificación tocada en segundo plano: ${respuesta.payload ?? ''}',
  );
}
