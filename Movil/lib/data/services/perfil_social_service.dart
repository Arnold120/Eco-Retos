import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/social_models.dart';

/// Perfil publico de un usuario con contadores sociales.
class PerfilSocialService {
  final ApiClient _client;

  PerfilSocialService(this._client);

  Future<PerfilPublicoResponse> getPerfilPublico(int usuarioId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.perfiles}/usuario/$usuarioId/publico',
      fromJson: PerfilPublicoResponse.fromJson,
    );
  }
}
