import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/main.dart' as app;
import 'package:eco_reto/ui/community/community_screen.dart';
import 'package:eco_reto/ui/widgets/user_avatar.dart';

const _correoA = 'auditor.qa.eco@test.local';
const _correoB = 'qa.bob@test.local';
const _contrasena = 'Auditor123!';
const _mensajeViejo = 'Mensaje antiguo de QA';
const _mensaje = 'Hola desde la prueba de chat';
const _mensajeNuevo = 'Respuesta enviada desde la app';

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
      'Apellido': 'Chat',
    });
  } catch (_) {
    // Ya existe.
  }
}

Future<Map<String, dynamic>> _login(String correo) async {
  final r = await _dio.post('/Auth/login', data: {
    'Correo': correo,
    'Contrasena': _contrasena,
  });
  return r.data as Map<String, dynamic>;
}

Options _auth(String token) =>
    Options(headers: {'Authorization': 'Bearer $token'});

/// Bob abre una conversacion con el auditor y le envia un mensaje.
Future<void> _prepararConversacion() async {
  await _registrar('auditor_qa_eco', _correoA);
  await _registrar('qa_bob', _correoB);

  final a = await _login(_correoA);
  final b = await _login(_correoB);
  final tokenB = b['token'] as String;
  final idA = a['usuario']['usuarioId'] as int;

  final conversacion = await _dio.post(
    '/Conversaciones',
    options: _auth(tokenB),
    data: {'UsuarioId': idA},
  );
  final conversacionId = conversacion.data['conversacionId'] as int;

  await _dio.post(
    '/Conversaciones/$conversacionId/mensajes',
    options: _auth(tokenB),
    data: {'Contenido': _mensajeViejo},
  );
  await _dio.post(
    '/Conversaciones/$conversacionId/mensajes',
    options: _auth(tokenB),
    data: {'Contenido': _mensaje},
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('el chat se abre dentro del Muro con mensajes y foto',
      (tester) async {
    await _prepararConversacion();

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

    // Muro -> Mensajes
    await tester.tap(find.text('Muro'));
    await avanzar(tester, const Duration(seconds: 6));
    await tester.tap(
      find.descendant(
        of: find.byType(CommunityScreen),
        matching: find.text('Mensajes'),
      ),
    );
    await avanzar(tester, const Duration(seconds: 6));

    // Abrir la conversacion con Bob: debe ir a pantalla completa.
    expect(find.text('qa_bob'), findsWidgets,
        reason: 'La conversacion debe aparecer en la lista');
    await tester.tap(find.text('qa_bob').first);
    await avanzar(tester, const Duration(seconds: 6));

    // El chat a pantalla completa muestra el mensaje mas reciente.
    expect(find.text(_mensaje), findsWidgets,
        reason: 'El mensaje mas reciente debe verse al abrir el chat');
    expect(find.byType(UserAvatar), findsWidgets,
        reason: 'El avatar/foto del usuario debe mostrarse en el chat');
    expect(find.byTooltip('Volver a mensajes'), findsWidgets,
        reason: 'Debe poder volver a la lista');

    // Enviar un mensaje desde la app: debe quedar visible el mas reciente.
    await tester.enterText(find.byType(TextField).last, _mensajeNuevo);
    await avanzar(tester, const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Enviar mensaje'));
    await avanzar(tester, const Duration(seconds: 6));
    expect(find.text(_mensajeNuevo), findsWidgets,
        reason: 'Al enviar, el chat debe mostrar el mensaje mas reciente');

    // Volver restaura la navegacion del Muro.
    await tester.tap(find.byTooltip('Volver a mensajes'));
    await avanzar(tester, const Duration(seconds: 5));
    expect(find.text('Muro Eco'), findsWidgets);
    expect(find.text('Retos'), findsWidgets);
  });
}
