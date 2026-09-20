import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/social_models.dart';

class CalificacionService {
  final ApiClient _client;

  CalificacionService(this._client);

  Future<ResumenCalificaciones> getResumen(int usuarioId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.calificaciones}/$usuarioId',
      fromJson: ResumenCalificaciones.fromJson,
    );
  }

  Future<ResumenCalificaciones> calificar(
    int usuarioId, {
    required int calificacion,
    String? comentario,
  }) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.calificaciones}/$usuarioId',
      body: CalificarPerfilRequest(
        calificacion: calificacion,
        comentario: comentario,
      ).toJson(),
      fromJson: ResumenCalificaciones.fromJson,
    );
  }

  Future<void> eliminar(int usuarioId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.calificaciones}/$usuarioId',
    );
  }
}