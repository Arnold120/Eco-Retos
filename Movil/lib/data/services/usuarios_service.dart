import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/admin/admin_models.dart';





class UsuariosService {
  final ApiClient _client;

  UsuariosService(this._client);


  Future<List<UsuarioAdminResponse>> listarUsuarios() {
    return ApiHelper.getList(
      _client,
      ApiConstants.usuarios,
      fromJson: UsuarioAdminResponse.fromJson,
    );
  }


  Future<UsuariosTotalesResponse> obtenerTotales() {
    return ApiHelper.get(
      _client,
      '${ApiConstants.usuarios}/totales',
      fromJson: UsuariosTotalesResponse.fromJson,
    );
  }


  Future<List<RolResponse>> listarRoles() {
    return ApiHelper.getList(
      _client,
      ApiConstants.roles,
      fromJson: RolResponse.fromJson,
    );
  }


  Future<void> activar(int usuarioId) {
    return ApiHelper.postVoid(
      _client,
      '${ApiConstants.usuarios}/$usuarioId/activar',
    );
  }


  Future<void> desactivar(int usuarioId) {
    return ApiHelper.postVoid(
      _client,
      '${ApiConstants.usuarios}/$usuarioId/desactivar',
    );
  }


  Future<void> asignarRol(int usuarioId, int rolId) {
    return ApiHelper.postVoid(
      _client,
      ApiConstants.usuariosRoles,
      body: {'usuarioId': usuarioId, 'rolId': rolId},
    );
  }


  Future<void> quitarRol(int usuarioId, int rolId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.usuariosRoles}/$usuarioId/rol/$rolId',
    );
  }
}
