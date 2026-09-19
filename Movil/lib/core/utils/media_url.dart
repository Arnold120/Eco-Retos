import 'package:flutter/foundation.dart';

import '../config/env_config.dart';








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
