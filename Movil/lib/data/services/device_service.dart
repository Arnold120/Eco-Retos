import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class DeviceService {
  final ApiClient _client;

  DeviceService(this._client);

  Future<void> registrarToken(String token) async {
    await _client.dio.post(
      '${ApiConstants.dispositivos}/token',
      data: {
        'token': token,
        'plataforma': _plataformaActual(),
      },
    );
  }

  Future<void> desactivarToken(String token) async {
    await _client.dio.delete(
      '${ApiConstants.dispositivos}/token',
      data: {'token': token},
    );
  }

  String _plataformaActual() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
