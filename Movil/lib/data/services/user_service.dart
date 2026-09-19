import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/user/user_models.dart';

class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<PerfilResponse> getPerfil(int usuarioId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.perfiles}/usuario/$usuarioId',
      fromJson: PerfilResponse.fromJson,
    );
  }

  Future<PerfilResponse> actualizarPerfil(
    int perfilId,
    ActualizarPerfilRequest request,
  ) {
    return ApiHelper.put(
      _client,
      '${ApiConstants.perfiles}/$perfilId',
      body: request.toJson(),
      fromJson: PerfilResponse.fromJson,
    );
  }
}
