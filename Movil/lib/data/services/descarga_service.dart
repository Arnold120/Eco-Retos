import 'dart:io';

import 'package:dio/dio.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/media_url.dart';







class DescargaService {
  static const String carpetaApp = 'EcoReto';

  final ApiClient _client;

  DescargaService(this._client);

  Future<String> descargar(
    String url, {
    String tipo = 'imagen',
    String? nombreSugerido,
    void Function(double progreso)? onProgress,
  }) async {
    final yaIntentoPermiso = await _permisoYaIntentado();

    final resuelta = resolverUrlMedia(url) ?? url;
    final subcarpeta = tipo == 'video' ? 'videos' : 'imagenes';
    final nombre = _nombreArchivo(resuelta, tipo, nombreSugerido);
    final temporal = await _archivoTemporal(nombre);

    try {
      await _client.dio.download(
        resuelta,
        temporal.path,
        onReceiveProgress: (recibidos, total) {
          if (total > 0) onProgress?.call(recibidos / total);
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException {
      if (await temporal.exists()) {
        await temporal.delete().catchError((_) => temporal);
      }
      throw const ApiException(
        statusCode: 0,
        message: 'No se pudo descargar el archivo. Revisa tu conexión.',
      );
    }

    if (Platform.isAndroid) {




      try {
        await MediaStore.ensureInitialized();
        MediaStore.appFolder = carpetaApp;
        final info = await MediaStore().saveFile(
          tempFilePath: temporal.path,
          dirType: DirType.download,
          dirName: DirName.download,
          relativePath: '$carpetaApp/$subcarpeta',
        );
        await _marcarPermisoIntentado();
        if (info != null && info.name.isNotEmpty) {
          return 'Download/$carpetaApp/$subcarpeta/${info.name}';
        }
      } catch (_) {
        await _marcarPermisoIntentado();
      }


      if (!await temporal.exists()) {
        return 'Download/$carpetaApp/$subcarpeta/$nombre';
      }

      if (yaIntentoPermiso) {
        final documentos = await getApplicationDocumentsDirectory();
        return _moverA(
          temporal,
          Directory('${documentos.path}/$carpetaApp/$subcarpeta'),
          nombre,
        );
      }
    } else {
      final descargas = await getDownloadsDirectory();
      if (descargas != null) {
        return _moverA(
          temporal,
          Directory('${descargas.path}/$carpetaApp/$subcarpeta'),
          nombre,
        );
      }
    }

    final documentos = await getApplicationDocumentsDirectory();
    return _moverA(
      temporal,
      Directory('${documentos.path}/$carpetaApp/$subcarpeta'),
      nombre,
    );
  }




  Future<bool> _permisoYaIntentado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('permiso_almacenamiento_solicitado') == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _marcarPermisoIntentado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permiso_almacenamiento_solicitado', true);
    } catch (_) {

    }
  }

  Future<String> _moverA(File temporal, Directory carpeta, String nombre) async {
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    final destino = File('${carpeta.path}${Platform.pathSeparator}$nombre');
    await temporal.copy(destino.path);
    await temporal.delete();
    return destino.path;
  }

  Future<File> _archivoTemporal(String nombre) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}${Platform.pathSeparator}$nombre');
  }

  String _nombreArchivo(String url, String tipo, String? nombreSugerido) {
    final uri = Uri.tryParse(url);
    var nombre = '';
    if (uri != null && uri.pathSegments.isNotEmpty) {
      nombre = uri.pathSegments.last;
    }
    if (nombre.isEmpty || !nombre.contains('.')) {
      final extension = tipo == 'video' ? 'mp4' : 'jpg';
      final base = (nombreSugerido ?? 'ecoreto')
          .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
      nombre = '${base}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    }

    final punto = nombre.lastIndexOf('.');
    if (punto > 0) {
      final base = nombre.substring(0, punto);
      final ext = nombre.substring(punto);
      nombre = '${base}_${DateTime.now().millisecondsSinceEpoch}$ext';
    }
    return nombre;
  }
}
