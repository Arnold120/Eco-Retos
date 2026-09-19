import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/main.dart' as app;

const _correo = 'qa.pantallas@test.local';
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
      'NombreUsuario': 'qa_pantallas',
      'Correo': _correo,
      'Contrasena': _contrasena,
      'Nombre': 'QA',
      'Apellido': 'Pantallas',
    });
  } catch (_) {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard, trivia y perfil cargan sin error', (tester) async {
    await _asegurarCuenta();
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'auth_roles');

    app.main();
    await avanzar(tester, const Duration(seconds: 6));

    final botonLogin = find.widgetWithText(ElevatedButton, 'Iniciar sesión');
    if (botonLogin.evaluate().isNotEmpty) {
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), _correo);
      await tester.enterText(campos.at(1), _contrasena);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(botonLogin);
      await avanzar(tester, const Duration(seconds: 14));
    }

    // Dashboard (Para ti)
    await avanzar(tester, const Duration(seconds: 6));
    expect(find.text('Accesos rápidos'), findsWidgets,
        reason: 'El dashboard debe cargar sus secciones');

    // Pestana (barra inferior en movil, rail en pantallas anchas).
    Finder destino(String label) {
      final enRail = find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(label),
      );
      if (enRail.evaluate().isNotEmpty) return enRail;
      return find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text(label),
      );
    }

    await tester.tap(destino('Trivia'));
    await avanzar(tester, const Duration(seconds: 10));
    expect(find.text('Trivia Eco'), findsWidgets,
        reason: 'La pantalla de trivias debe cargar');

    await tester.tap(destino('Perfil'));
    await avanzar(tester, const Duration(seconds: 10));
    expect(find.text('Mi Perfil'), findsWidgets,
        reason: 'El perfil debe cargar');
  });
}
