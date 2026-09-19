import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/main.dart' as app;
import 'package:eco_reto/ui/community/community_screen.dart';
import 'package:eco_reto/ui/community/cubit/community_cubit.dart';

const _correo = 'auditor.qa.eco@test.local';
const _contrasena = 'Auditor123!';


Future<void> _asegurarCuenta() async {
  try {
    await Dio().post(
      '${EnvConfig.baseUrl}/Auth/registrar',
      data: {
        'NombreUsuario': 'auditor_qa_eco',
        'Correo': _correo,
        'Contrasena': _contrasena,
        'Nombre': 'Auditor',
        'Apellido': 'QA',
      },
    );
  } catch (_) {

  }
}




Future<void> avanzar(WidgetTester tester, Duration duracion) async {
  final fin = DateTime.now().add(duracion);
  while (DateTime.now().isBefore(fin)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}




void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('publicar conserva las publicaciones existentes',
      (tester) async {
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
      await avanzar(tester, const Duration(seconds: 12));
    }


    await tester.tap(find.text('Muro'));
    await avanzar(tester, const Duration(seconds: 10));


    for (final label in [
      'Inicio',
      'Usuarios',
      'Mensajes',
      'Alertas',
      'Guardados',
      'Perfil',
    ]) {
      expect(
        find.descendant(
          of: find.byType(CommunityScreen),
          matching: find.text(label),
        ),
        findsWidgets,
        reason: 'El Muro Eco debe mostrar el acceso "$label"',
      );
    }
    expect(find.text('Muro Eco'), findsWidgets);
    expect(find.text('Buscar en Eco Retos…'), findsWidgets);



    Future<void> comprobarBarras(String seccion) async {
      expect(find.text('Muro Eco'), findsWidgets,
          reason: 'Falta el encabezado del Muro en $seccion');
      expect(find.text('Retos'), findsWidgets,
          reason: 'Falta la barra inferior general en $seccion');
      expect(
        find.descendant(
          of: find.byType(CommunityScreen),
          matching: find.text('Inicio'),
        ),
        findsWidgets,
        reason: 'Falta la navegacion del Muro en $seccion',
      );
    }

    for (final seccion in [
      'Usuarios',
      'Mensajes',
      'Alertas',
      'Guardados',
      'Perfil',
    ]) {
      await tester.tap(
        find.descendant(
          of: find.byType(CommunityScreen),
          matching: find.text(seccion),
        ),
      );
      await avanzar(tester, const Duration(seconds: 4));
      await comprobarBarras(seccion);
      if (seccion == 'Perfil') {

        expect(find.text('Publicaciones'), findsWidgets,
            reason: 'El perfil del Muro debe listar publicaciones');
      }
    }


    await tester.tap(
      find.descendant(
        of: find.byType(CommunityScreen),
        matching: find.text('Inicio'),
      ),
    );
    await avanzar(tester, const Duration(seconds: 6));
    await comprobarBarras('Inicio');



    final contextoMuro = tester.element(find.byType(CommunityScreen));
    final cubit = BlocProvider.of<CommunityCubit>(contextoMuro);
    final antes = cubit.state.publicaciones.length;
    debugPrint('E2E: publicaciones en estado antes = $antes');
    expect(antes, greaterThan(0),
        reason: 'El muro debe mostrar publicaciones antes de publicar');


    await tester.tap(find.text('Publicar').first);
    await avanzar(tester, const Duration(seconds: 3));
    final texto = 'Prueba E2E ${DateTime.now().millisecondsSinceEpoch}';
    await tester.enterText(find.byType(TextField).first, texto);
    await avanzar(tester, const Duration(seconds: 2));
    await tester.tap(find.widgetWithText(FilledButton, 'Publicar'));
    await avanzar(tester, const Duration(seconds: 12));

    final despues = cubit.state.publicaciones.length;
    final contieneNueva =
        cubit.state.publicaciones.any((p) => p.contenido.contains(texto));
    debugPrint(
        'E2E: publicaciones en estado después = $despues, contieneNueva=$contieneNueva');
    expect(contieneNueva, isTrue,
        reason: 'La publicación nueva debe aparecer en el muro');
    expect(despues, greaterThanOrEqualTo(antes + 1),
        reason: 'No deben desaparecer las publicaciones anteriores');
  });
}
