import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canal Android con sonido propio. El id incluye versión porque los canales
/// de Android son inmutables: si se cambia el sonido hay que crear uno nuevo.
const String kCanalNotificacionesId = 'eco_reto_notificaciones_v1';
const String kCanalNotificacionesNombre = 'Notificaciones Eco-Retos';
const String kCanalNotificacionesDescripcion =
    'Avisos de retos, comunidad, mensajes y soporte con el sonido de la app.';
const String kSonidoNotificacion = 'notificacion';

/// Maneja las notificaciones locales que se muestran aunque la app esté en
/// primer plano, segundo plano o cerrada. También centraliza el sonido
/// `res/raw/notificacion.mp3` mediante el canal de Android.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _aperturas =
      StreamController<String>.broadcast();

  /// Payload de las notificaciones que el usuario toca.
  Stream<String> get aperturas => _aperturas.stream;

  /// Permite a otros servicios (por ejemplo FCM) notificar una apertura.
  void emitirApertura(String payload) {
    if (payload.isNotEmpty) _aperturas.add(payload);
  }

  bool _inicializado = false;
  int _contador = 0;

  /// Payload de una notificación local que abrió la app estando cerrada.
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

  /// Inicializa el plugin, crea el canal con `notificacion.mp3` y engancha los
  /// toques del usuario. Se puede llamar varias veces sin efectos duplicados.
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

    // Si la app se abrió desde una notificación local con la app cerrada,
    // se guarda el payload para navegar cuando haya sesión.
    try {
      final detalles = await _plugin.getNotificationAppLaunchDetails();
      final payload = detalles?.notificationResponse?.payload;
      if (detalles?.didNotificationLaunchApp == true &&
          payload != null &&
          payload.isNotEmpty) {
        payloadInicial = payload;
      }
    } catch (_) {
      // Sin detalles de arranque: no es crítico.
    }

    _inicializado = true;
    if (background) {
      debugPrint('NotificationService inicializado en segundo plano.');
    }
  }

  /// Muestra una notificación local con el sonido obligatorio de la app.
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

  /// Interpreta un mensaje de FCM y lo muestra como notificación local.
  ///
  /// - Mensajes de datos (data-only): se muestran siempre con `notificacion.mp3`.
  /// - Mensajes con bloque `notification` en primer plano: Android no los
  ///   muestra solo, así que también se muestran aquí.
  /// - Mensajes con bloque `notification` en segundo plano/cerrada: los
  ///   muestra el sistema usando el canal por defecto configurado en el
  ///   AndroidManifest (`eco_reto_notificaciones_v1`), por lo que NO se
  ///   duplican desde la app.
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
      // El sistema ya la muestra con el canal por defecto.
      return;
    }

    if (cuerpo.isEmpty && titulo == 'Eco-Retos') return;

    await mostrar(
      titulo: titulo,
      cuerpo: cuerpo,
      payload: data['payload']?.toString() ?? data['referencia']?.toString(),
    );
  }

  /// Pide permiso de notificaciones en Android 13+ (por si el flujo de
  /// permisos de la app aún no lo solicitó).
  Future<bool> solicitarPermisoAndroid() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.requestNotificationsPermission() ?? true;
  }

  /// Cancela todas las notificaciones mostradas.
  Future<void> cancelarTodas() => _plugin.cancelAll();
}

/// Callback que ejecuta Android cuando el usuario toca una notificación con la
/// app cerrada. Debe ser de nivel superior y con anotación de entry-point.
@pragma('vm:entry-point')
void _respuestaEnSegundoPlano(NotificationResponse respuesta) {
  // La app se abrirá y `getInitialMessage` de FCM entrega el payload.
  debugPrint(
    'Notificación tocada en segundo plano: ${respuesta.payload ?? ''}',
  );
}
