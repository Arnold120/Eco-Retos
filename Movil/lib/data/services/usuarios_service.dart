import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/admin/admin_models.dart';

/// Operaciones exclusivas del administrador sobre usuarios y roles.
///
/// Todos sus endpoints exigen el rol ADMIN en el backend; cualquier otro
/// rol recibe 403.
class UsuariosService {
  final ApiClient _client;

  UsuariosService(this._client);

  /// Todos los usuarios con sus roles.
  Future<List<UsuarioAdminResponse>> listarUsuarios() {
    return ApiHelper.getList(
      _client,
      ApiConstants.usuarios,
      fromJson: UsuarioAdminResponse.fromJson,
    );
  }

  /// Conteos globales (total, activos, inactivos).
  Future<UsuariosTotalesResponse> obtenerTotales() {
    return ApiHelper.get(
      _client,
      '${ApiConstants.usuarios}/totales',
      fromJson: UsuariosTotalesResponse.fromJson,
    );
  }

  /// Catálogo de roles del sistema (para asignar/quitar roles).
  Future<List<RolResponse>> listarRoles() {
    return ApiHelper.getList(
      _client,
      ApiConstants.roles,
      fromJson: RolResponse.fromJson,
    );
  }

  /// Activa una cuenta.
  Future<void> activar(int usuarioId) {
    return ApiHelper.postVoid(
      _client,
      '${ApiConstants.usuarios}/$usuarioId/activar',
    );
  }

  /// Desactiva una cuenta (el usuario ya no podrá acceder).
  Future<void> desactivar(int usuarioId) {
    return ApiHelper.postVoid(
      _client,
      '${ApiConstants.usuarios}/$usuarioId/desactivar',
    );
  }

  /// Asigna un rol a un usuario.
  Future<void> asignarRol(int usuarioId, int rolId) {
    return ApiHelper.postVoid(
      _client,
      ApiConstants.usuariosRoles,
      body: {'usuarioId': usuarioId, 'rolId': rolId},
    );
  }

  /// Quita un rol a un usuario.
  Future<void> quitarRol(int usuarioId, int rolId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.usuariosRoles}/$usuarioId/rol/$rolId',
    );
  }
}
