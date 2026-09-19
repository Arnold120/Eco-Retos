import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/challenge/challenge_models.dart';

/// Operaciones exclusivas del administrador para revisar y resolver
/// evidencias enviadas por los estudiantes.
///
/// Todos sus endpoints exigen el rol ADMIN (atributo `[Authorize(Roles =
/// "ADMIN")]` en el backend); cualquier otro rol recibe 403.
class AdminService {
  final ApiClient _client;

  AdminService(this._client);

  /// Evidencias enviadas por estudiantes y aún sin decidir.
  Future<List<UsuarioRetoResponse>> obtenerEvidenciasPendientes() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/evidencias-pendientes',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  /// Todas las evidencias enviadas (cualquier estado): historial de revisión.
  Future<List<UsuarioRetoResponse>> obtenerEvidencias() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/evidencias',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  /// Acepta una evidencia: el reto queda COMPLETADO con sus puntos.
  Future<void> aprobarEvidencia(int usuarioRetoId, int puntos) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/aprobar',
      body: {'PuntosObtenidos': puntos},
    );
  }

  /// Rechaza una evidencia con un motivo que el estudiante verá.
  Future<void> rechazarEvidencia(int usuarioRetoId, String motivo) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/rechazar',
      body: {'Motivo': motivo},
    );
  }
}
