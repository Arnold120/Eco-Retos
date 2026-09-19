import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Configuración de Firebase para Eco-Retos.
///
/// IMPORTANTE: aquí no se guarda ninguna clave real. Los valores se leen de
/// variables de compilación para no exponer credenciales en el repositorio.
///
/// Opción A (recomendada): ejecuta en la carpeta del proyecto
///   flutterfire configure
/// y pega los valores generados en las constantes de abajo (o reemplaza
/// este archivo por el `firebase_options.dart` que genera la herramienta,
/// conservando el nombre de la clase `FirebaseConfig`).
///
/// Opción B: compila pasando los valores:
///   flutter build apk ^
///     --dart-define=FIREBASE_API_KEY=... ^
///     --dart-define=FIREBASE_APP_ID=... ^
///     --dart-define=FIREBASE_MESSAGING_SENDER_ID=... ^
///     --dart-define=FIREBASE_PROJECT_ID=... ^
///     --dart-define=FIREBASE_STORAGE_BUCKET=...
///
/// Si no se configura nada, la app sigue funcionando con notificaciones
/// locales (flutter_local_notifications); FCM queda desactivado.
class FirebaseConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String projectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static const String androidPackage = 'com.example.eco_reto';
  static const String iosBundleId = 'com.example.ecoReto';

  /// true solo cuando hay credenciales suficientes para inicializar Firebase.
  static bool get disponible =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  /// Opciones según la plataforma. Devuelve null si no está configurado.
  static FirebaseOptions? get currentPlatform {
    if (!disponible) return null;
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
          iosBundleId: iosBundleId,
        );
      default:
        return null;
    }
  }
}
