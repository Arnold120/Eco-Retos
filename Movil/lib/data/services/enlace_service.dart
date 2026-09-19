import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/enlace_preview.dart';

class EnlaceService {
  final ApiClient _client;

  EnlaceService(this._client);

  Future<EnlacePreview> obtenerPreview(String url) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.enlaces}/preview',
      queryParameters: {'url': url},
      fromJson: EnlacePreview.fromJson,
    );
  }
}
