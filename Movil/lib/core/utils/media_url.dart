import 'package:flutter/foundation.dart';

import '../config/env_config.dart';

/// Reescribe las URLs de archivos subidos a la API (`/api/Imagenes/...`) para
/// que apunten al host actual del backend.
///
/// Los archivos se guardan con la URL absoluta del host que atendió la subida
/// (túnel de desarrollo, localhost, etc.). Cuando ese host cambia, las URLs
/// antiguas quedan muertas; esta función las rescata conservando la ruta.
/// Las URLs externas (imágenes de Internet) se dejan intactas.
String? resolverUrlMedia(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final texto = url.trim();

  final uri = Uri.tryParse(texto);
  if (uri == null || !uri.hasScheme) return texto;
  if (!uri.path.contains('/api/Imagenes/')) return texto;

  final base = Uri.tryParse(EnvConfig.baseUrl);
  if (base == null || base.host.isEmpty) return texto;

  try {
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
    ).toString();
  } catch (e) {
    debugPrint('resolverUrlMedia: $e');
    return texto;
  }
}
