import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/social_models.dart';

class MensajeService {
  final ApiClient _client;

  MensajeService(this._client);

  Future<List<ConversacionResumen>> getConversaciones() {
    return ApiHelper.getList(
      _client,
      ApiConstants.conversaciones,
      fromJson: ConversacionResumen.fromJson,
    );
  }

  Future<int> getConteoNoLeidos() async {
    final response = await _client.dio.get(
      '${ApiConstants.conversaciones}/no-leidos/total',
    );
    return response.data['total'] ?? 0;
  }


  Future<ConversacionResumen> abrirConversacion(int usuarioId) {
    return ApiHelper.post(
      _client,
      ApiConstants.conversaciones,
      body: {'UsuarioId': usuarioId},
      fromJson: ConversacionResumen.fromJson,
    );
  }

  Future<List<MensajeResponse>> getMensajes(
    int conversacionId, {
    int? antesDe,
    int limite = 40,
  }) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.conversaciones}/$conversacionId/mensajes',
      queryParameters: {
        'limite': limite,
        if (antesDe != null) 'antesDe': antesDe,
      },
      fromJson: MensajeResponse.fromJson,
    );
  }

  Future<MensajeResponse> enviarMensaje(
    int conversacionId,
    String contenido, {
    String tipo = 'TEXTO',
    String? archivoUrl,
    int? publicacionId,
    int? respuestaAId,
  }) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.conversaciones}/$conversacionId/mensajes',
      body: {
        'Contenido': contenido,
        'Tipo': tipo,
        if (archivoUrl != null) 'ArchivoUrl': archivoUrl,
        if (publicacionId != null) 'PublicacionId': publicacionId,
        if (respuestaAId != null) 'RespuestaAId': respuestaAId,
      },
      fromJson: MensajeResponse.fromJson,
    );
  }

  Future<MensajeResponse> editarMensaje(
    int conversacionId,
    int mensajeId,
    String contenido,
  ) {
    return ApiHelper.put(
      _client,
      '${ApiConstants.conversaciones}/$conversacionId/mensajes/$mensajeId',
      body: {'Contenido': contenido},
      fromJson: MensajeResponse.fromJson,
    );
  }

  Future<void> eliminarMensaje(
    int conversacionId,
    int mensajeId, {
    bool paraTodos = false,
  }) async {
    await _client.dio.delete(
      '${ApiConstants.conversaciones}/$conversacionId/mensajes/$mensajeId',
      queryParameters: {'paraTodos': paraTodos},
    );
  }

  Future<void> marcarLeidos(int conversacionId) {
    return ApiHelper.postVoid(
      _client,
      '${ApiConstants.conversaciones}/$conversacionId/leidos',
    );
  }
}
