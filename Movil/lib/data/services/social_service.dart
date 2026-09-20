import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/social_models.dart';

class PublicacionService {
  final ApiClient _client;

  PublicacionService(this._client);

  Future<List<PublicacionResponse>> getPublicaciones() {
    return ApiHelper.getList(
      _client,
      ApiConstants.publicaciones,
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<List<PublicacionResponse>> getPublicacionesActivas() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.publicaciones}/activas',
      fromJson: PublicacionResponse.fromJson,
    );
  }



  Future<List<PublicacionResponse>> getFeed({
    int pagina = 1,
    int tamano = 10,
    int? autorId,
    bool siguiendo = false,
  }) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.publicaciones}/feed',
      queryParameters: {
        'pagina': pagina,
        'tamano': tamano,
        if (autorId != null) 'autorId': autorId,
        if (siguiendo) 'siguiendo': true,
      },
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<List<PublicacionResponse>> getRecientes(int cantidad) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.publicaciones}/recientes/$cantidad',
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<List<PublicacionResponse>> getPublicacionesPorUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.publicaciones}/usuario/$usuarioId',
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<PublicacionResponse> getPublicacion(int publicacionId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.publicaciones}/$publicacionId',
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<List<PublicacionResponse>> getMenciones(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.publicaciones}/menciones/$usuarioId',
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<List<PublicacionResponse>> buscar(String termino, {int limite = 20}) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.publicaciones}/buscar',
      queryParameters: {'q': termino, 'limite': limite},
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<PublicacionResponse> crearPublicacion(
      CrearPublicacionRequest request) {
    return ApiHelper.post(
      _client,
      ApiConstants.publicaciones,
      body: request.toJson(),
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<PublicacionResponse> actualizarPublicacion(
    int publicacionId,
    ActualizarPublicacionRequest request,
  ) {
    return ApiHelper.put(
      _client,
      '${ApiConstants.publicaciones}/$publicacionId',
      body: request.toJson(),
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<void> eliminarPublicacion(int publicacionId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.publicaciones}/$publicacionId',
    );
  }

  Future<List<PublicacionResponse>> getPublicacionesGuardadas() {
    return ApiHelper.getList(
      _client,
      ApiConstants.guardados,
      fromJson: PublicacionResponse.fromJson,
    );
  }

  Future<List<ComentarioResponse>> getComentarios(int publicacionId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.comentarios}/publicacion/$publicacionId',
      fromJson: ComentarioResponse.fromJson,
    );
  }

  Future<ComentarioResponse> crearComentario(
      CrearComentarioRequest request) {
    return ApiHelper.post(
      _client,
      ApiConstants.comentarios,
      body: request.toJson(),
      fromJson: ComentarioResponse.fromJson,
    );
  }

  Future<ComentarioResponse> actualizarComentario(
      int comentarioId, String texto) {
    return ApiHelper.put(
      _client,
      '${ApiConstants.comentarios}/$comentarioId',
      body: {'ComentarioTexto': texto},
      fromJson: ComentarioResponse.fromJson,
    );
  }

  Future<void> eliminarComentario(int comentarioId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.comentarios}/$comentarioId',
    );
  }
}

class NotificacionService {
  final ApiClient _client;

  NotificacionService(this._client);

  Future<List<NotificacionResponse>> getNotificaciones(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.notificaciones}/usuario/$usuarioId',
      fromJson: NotificacionResponse.fromJson,
    );
  }

  Future<List<NotificacionResponse>> getNoLeidas(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.notificaciones}/usuario/$usuarioId/no-leidas',
      fromJson: NotificacionResponse.fromJson,
    );
  }

  Future<int> getConteoNoLeidas(int usuarioId) async {
    final response = await _client.dio.get(
      '${ApiConstants.notificaciones}/usuario/$usuarioId/no-leidas/total',
    );
    return response.data['total'] ?? 0;
  }

  Future<void> marcarLeida(int notificacionId) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.notificaciones}/$notificacionId/leida',
    );
  }

  Future<void> marcarTodasLeidas(int usuarioId) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.notificaciones}/usuario/$usuarioId/leidas',
    );
  }

  Future<void> eliminar(int notificacionId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.notificaciones}/$notificacionId',
    );
  }

  Future<void> eliminarTodas(int usuarioId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.notificaciones}/usuario/$usuarioId',
    );
  }
}
