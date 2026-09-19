import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/main.dart' as app;
import 'package:eco_reto/ui/app/main_shell.dart';

const _correo = 'qa.sesion@test.local';
const _contrasena = 'QaTest123!';

final _dio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));

Future<void> avanzar(WidgetTester tester, Duration duracion) async {
  final fin = DateTime.now().add(duracion);
  while (DateTime.now().isBefore(fin)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _asegurarCuenta() async {
  try {
    await _dio.post('/Auth/registrar', data: {
      'NombreUsuario': 'qa_sesion',
      'Correo': _correo,
      'Contrasena': _contrasena,
      'Nombre': 'QA',
      'Apellido': 'Sesion',
    });
  } catch (_) {
    // Ya existe.
  }
}

/// Borra la sesion guardada para probar el login desde cero.
Future<void> _limpiarSesion() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  await storage.delete(key: 'auth_token');
  await storage.delete(key: 'auth_roles');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la sesion se mantiene al reiniciar la aplicacion',
      (tester) async {
    await _asegurarCuenta();
    await _limpiarSesion();

    app.main();
    await avanzar(tester, const Duration(seconds: 6));

    final botonLogin = find.widgetWithText(ElevatedButton, 'Iniciar sesión');
    expect(botonLogin, findsOneWidget,
        reason: 'Sin sesión guardada debe mostrar el login');
    final campos = find.byType(TextFormField);

    // Credenciales incorrectas: mensaje claro y campos conservados.
    await tester.enterText(campos.at(0), _correo);
    await tester.enterText(campos.at(1), 'clave-incorrecta');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(botonLogin);
    await avanzar(tester, const Duration(seconds: 10));
    expect(
      find.text('Credenciales no válidas. Revisa tu correo y contraseña.'),
      findsWidgets,
      reason: 'Debe avisar que las credenciales no son válidas',
    );
    expect(find.text(_correo), findsWidgets,
        reason: 'El correo escrito debe conservarse');
    expect(find.text('clave-incorrecta'), findsWidgets,
        reason: 'La contraseña escrita debe conservarse');

    // Ahora con la contraseña correcta.
    await tester.ensureVisible(campos.at(1));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(campos.at(1));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(campos.at(1), _contrasena);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.ensureVisible(botonLogin);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(botonLogin);
    await avanzar(tester, const Duration(seconds: 14));
    expect(find.byType(MainShell), findsOneWidget,
        reason: 'Tras iniciar sesión debe entrar al shell');

    // Simula cerrar y volver a abrir la app (nueva instancia del arbol).
    app.main();
    await avanzar(tester, const Duration(seconds: 12));

    expect(find.byType(MainShell), findsOneWidget,
        reason: 'La sesión guardada debe restaurarse sin volver a loguear');
    expect(botonLogin, findsNothing,
        reason: 'No debe pedir credenciales otra vez');
  });
}
