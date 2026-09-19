import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/trivia/trivia_models.dart';

class TriviaService {
  final ApiClient _client;

  TriviaService(this._client);

  Future<List<TriviaResponse>> getTrivias() {
    return ApiHelper.getList(
      _client,
      ApiConstants.trivias,
      fromJson: TriviaResponse.fromJson,
    );
  }

  Future<List<TriviaResponse>> getTriviasActivas() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.trivias}/activas',
      fromJson: TriviaResponse.fromJson,
    );
  }

  Future<TriviaResponse> getTriviaPorId(int id) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.trivias}/$id',
      fromJson: TriviaResponse.fromJson,
    );
  }

  Future<List<TriviaResponse>> getTriviasPorCategoria(int categoriaId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.trivias}/categoria/$categoriaId',
      fromJson: TriviaResponse.fromJson,
    );
  }

  Future<List<PreguntaResponse>> getPreguntasConOpciones(int triviaId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.preguntas}/trivia/$triviaId/con-opciones',
      fromJson: PreguntaResponse.fromJson,
    );
  }

  Future<IntentoTriviaResponse> iniciarIntento(int usuarioId, int triviaId) {
    return ApiHelper.post(
      _client,
      ApiConstants.intentosTrivia,
      body: {
        'UsuarioId': usuarioId,
        'TriviaId': triviaId,
      },
      fromJson: IntentoTriviaResponse.fromJson,
    );
  }

  Future<void> finalizarIntento(int intentoId, int puntuacion) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.intentosTrivia}/$intentoId/finalizar',
      body: {'Puntuacion': puntuacion},
    );
  }

  Future<RespuestaUsuarioResponse> registrarRespuesta(
    int intentoId,
    int preguntaId,
    int opcionId,
    bool esCorrecta,
  ) {
    return ApiHelper.post(
      _client,
      ApiConstants.respuestasUsuario,
      body: {
        'IntentoId': intentoId,
        'PreguntaId': preguntaId,
        'OpcionId': opcionId,
        'EsCorrecta': esCorrecta,
      },
      fromJson: RespuestaUsuarioResponse.fromJson,
    );
  }

  Future<List<IntentoTriviaResponse>> getIntentosUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.intentosTrivia}/usuario/$usuarioId',
      fromJson: IntentoTriviaResponse.fromJson,
    );
  }
}
