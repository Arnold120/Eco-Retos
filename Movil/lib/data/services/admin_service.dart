import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/challenge/challenge_models.dart';






class AdminService {
  final ApiClient _client;

  AdminService(this._client);


  Future<List<UsuarioRetoResponse>> obtenerEvidenciasPendientes() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/evidencias-pendientes',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }


  Future<List<UsuarioRetoResponse>> obtenerEvidencias() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/evidencias',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }


  Future<void> aprobarEvidencia(int usuarioRetoId, int puntos) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/aprobar',
      body: {'PuntosObtenidos': puntos},
    );
  }


  Future<void> rechazarEvidencia(int usuarioRetoId, String motivo) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/rechazar',
      body: {'Motivo': motivo},
    );
  }
}
