import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:eco_reto/core/config/env_config.dart';
import 'package:eco_reto/core/network/api_client.dart';
import 'package:eco_reto/data/services/descarga_service.dart';

const _correo = 'qa.descarga@test.local';
const _contrasena = 'QaTest123!';

// PNG 1x1 valido.
const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

final _dio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));

Future<String> _token() async {
  try {
    await _dio.post('/Auth/registrar', data: {
      'NombreUsuario': 'qa_descarga',
      'Correo': _correo,
      'Contrasena': _contrasena,
      'Nombre': 'QA',
      'Apellido': 'Descarga',
    });
  } catch (_) {
    // Ya existe.
  }
  final r = await _dio.post('/Auth/login', data: {
    'Correo': _correo,
    'Contrasena': _contrasena,
  });
  return r.data['token'] as String;
}

Future<String> _subirImagen(String token) async {
  final temp = await getTemporaryDirectory();
  final archivo = File('${temp.path}${Platform.pathSeparator}qa_descarga.png');
  await archivo.writeAsBytes(base64Decode(_pngBase64));
  final form = FormData.fromMap({
    'archivo': await MultipartFile.fromFile(
      archivo.path,
      filename: 'qa_descarga.png',
    ),
  });
  final r = await _dio.post(
    '/Imagenes',
    data: form,
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  return r.data['url'] as String;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la descarga guarda en EcoReto/imagenes', (tester) async {
    final token = await _token();
    final url = await _subirImagen(token);

    final service = DescargaService(ApiClient());
    final ruta = await service.descargar(
      url,
      tipo: 'imagen',
      nombreSugerido: 'qa_descarga',
    );

    debugPrint('E2E DESCARGA: $ruta');
    expect(ruta, contains('EcoReto'));
    expect(ruta, contains('imagenes'));

    final archivo = File(ruta);
    expect(await archivo.exists(), isTrue,
        reason: 'El archivo descargado debe existir en disco');
    expect(await archivo.length(), greaterThan(0),
        reason: 'El archivo no debe estar vacío');
  });
}
