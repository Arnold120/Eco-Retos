import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/main.dart' as app;
import 'package:eco_reto/ui/app/main_shell.dart';
import 'package:eco_reto/ui/notifications/cubit/notification_cubit.dart';

const _correoA = 'auditor.qa.eco@test.local';
const _correoB = 'qa.bob@test.local';
const _contrasena = 'Auditor123!';

final _dio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));

Future<void> avanzar(WidgetTester tester, Duration duracion) async {
  final fin = DateTime.now().add(duracion);
  while (DateTime.now().isBefore(fin)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _registrar(String usuario, String correo) async {
  try {
    await _dio.post('/Auth/registrar', data: {
      'NombreUsuario': usuario,
      'Correo': correo,
      'Contrasena': _contrasena,
      'Nombre': 'QA',
      'Apellido': 'Test',
    });
  } catch (_) {
    // Ya existe.
  }
}

Future<String> _token(String correo) async {
  final r = await _dio.post('/Auth/login', data: {
    'Correo': correo,
    'Contrasena': _contrasena,
  });
  return r.data['token'] as String;
}

Future<int> _usuarioId(String correo) async {
  final r = await _dio.post('/Auth/login', data: {
    'Correo': correo,
    'Contrasena': _contrasena,
  });
  return r.data['usuario']['usuarioId'] as int;
}

Options _auth(String token) =>
    Options(headers: {'Authorization': 'Bearer $token'});

/// Crea (si hace falta) una publicacion de A y le da me gusta desde B.
Future<int> _prepararInteraccion() async {
  await _registrar('auditor_qa_eco', _correoA);
  await _registrar('qa_bob', _correoB);

  final tokenA = await _token(_correoA);
  final tokenB = await _token(_correoB);
  final idA = await _usuarioId(_correoA);

  final publicaciones = await _dio.get(
    '/Publicaciones/usuario/$idA',
    options: _auth(tokenA),
  );
  int publicacionId;
  final lista = publicaciones.data as List;
  if (lista.isEmpty) {
    final creada = await _dio.post(
      '/Publicaciones',
      options: _auth(tokenA),
      data: {'UsuarioId': idA, 'Contenido': 'Publicación QA alertas', 'Tipo': 'GENERAL'},
    );
    publicacionId = creada.data['publicacionId'] as int;
  } else {
    publicacionId = lista.first['publicacionId'] as int;
  }

  await _dio.post(
    '/Reacciones',
    options: _auth(tokenB),
    data: {'PublicacionId': publicacionId, 'Tipo': 'ME_GUSTA'},
  );
  return publicacionId;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('las alertas muestran interacciones de otros usuarios',
      (tester) async {
    await _prepararInteraccion();

    app.main();
    await avanzar(tester, const Duration(seconds: 6));

    final botonLogin = find.widgetWithText(ElevatedButton, 'Iniciar sesión');
    if (botonLogin.evaluate().isNotEmpty) {
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), _correoA);
      await tester.enterText(campos.at(1), _contrasena);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(botonLogin);
      await avanzar(tester, const Duration(seconds: 12));
    }

    // Ir al Muro y abrir las alertas desde su header.
    await tester.tap(find.text('Muro'));
    await avanzar(tester, const Duration(seconds: 6));

    final contextoShell = tester.element(find.byType(MainShell));
    final cubit = BlocProvider.of<NotificationCubit>(contextoShell);
    await cubit.loadNotificaciones();
    await avanzar(tester, const Duration(seconds: 2));

    debugPrint(
        'E2E ALERTAS: total=${cubit.state.notificaciones.length} sinLeer=${cubit.state.noLeidas}');
    expect(cubit.state.notificaciones, isNotEmpty,
        reason: 'Debe haber alertas generadas por la interacción de Bob');
    expect(
      cubit.state.notificaciones.any((n) =>
          n.tipo == 'ME_GUSTA' || n.tipo == 'COMENTARIO' || n.tipo == 'SEGUIMIENTO'),
      isTrue,
      reason: 'Debe existir al menos una alerta de interacción',
    );

    // Abrir la pantalla desde el icono dentro de Muro Eco.
    await tester.tap(find.text('Alertas'));
    await avanzar(tester, const Duration(seconds: 4));
    expect(find.text('Notificaciones'), findsWidgets);

    // La lista debe estar realmente visible (sin animaciones que la oculten).
    final texto = find.textContaining('reaccion');
    expect(texto, findsWidgets);
    expect(tester.getSize(texto.first).height, greaterThan(0),
        reason: 'La alerta debe ocupar espacio visible en pantalla');
  });
}
