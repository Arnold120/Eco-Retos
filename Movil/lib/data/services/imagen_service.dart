import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';


class MediaSubida {
  final String url;
  final String tipo; 

  const MediaSubida({required this.url, required this.tipo});
}

class ImagenService {
  static const Set<String> extensionesVideo = {
    'mp4',
    'mov',
    'webm',
    'm4v',
  };
  static const Set<String> extensionesImagen = {
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
  };

  static const int maxImagenBytes = 8 * 1024 * 1024;
  static const int maxVideoBytes = 100 * 1024 * 1024;

  final ApiClient _client;

  ImagenService(this._client);

  static String extensionDe(String path) {
    final punto = path.lastIndexOf('.');
    if (punto < 0) return '';
    return path.substring(punto + 1).toLowerCase();
  }

  static bool esVideo(String path) =>
      extensionesVideo.contains(extensionDe(path));




  Future<MediaSubida> subirMedia(
    File archivo, {
    void Function(double progreso)? onProgress,
  }) async {
    if (archivo.path.trim().isEmpty) {
      throw const ApiException(
        statusCode: 0,
        message: 'El archivo no es válido.',
      );
    }

    final extension = extensionDe(archivo.path);
    final video = extensionesVideo.contains(extension);
    if (!video && !extensionesImagen.contains(extension)) {
      throw const ApiException(
        statusCode: 0,
        message: 'Formato no permitido. Usa imágenes o videos mp4/mov/webm.',
      );
    }

    final tamano = await archivo.length();
    final maximo = video ? maxVideoBytes : maxImagenBytes;
    if (tamano > maximo) {
      throw ApiException(
        statusCode: 0,
        message: video
            ? 'El video supera el tamaño máximo de 100 MB.'
            : 'La imagen supera el tamaño máximo de 8 MB.',
      );
    }

    final form = FormData.fromMap({
      'archivo': await MultipartFile.fromFile(
        archivo.path,
        filename: archivo.uri.pathSegments.last,
      ),
    });

    final respuesta = await _client.dio.post(
      ApiConstants.imagenes,
      data: form,
      onSendProgress: (enviados, total) {
        if (total > 0) onProgress?.call(enviados / total);
      },

      options: Options(
        sendTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    final data = respuesta.data;
    final url = data is Map ? (data['url'] as String?) : null;
    if (url == null || url.isEmpty) {
      throw const ApiException(
        statusCode: 0,
        message: 'El servidor no devolvió la URL del archivo.',
      );
    }

    final tipoRespuesta = data is Map ? data['tipo']?.toString() : null;
    return MediaSubida(
      url: url,
      tipo: tipoRespuesta == 'video'
          ? 'video'
          : (video ? 'video' : 'imagen'),
    );
  }

  Future<String> subirImagen(File archivo) async {
    final subida = await subirMedia(archivo);
    return subida.url;
  }
}
