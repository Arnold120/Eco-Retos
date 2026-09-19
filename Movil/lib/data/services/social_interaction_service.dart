import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/social_models.dart';


class ReaccionService {
  final ApiClient _client;

  ReaccionService(this._client);


  Future<ResultadoReaccion> alternar({
    int? publicacionId,
    int? comentarioId,
    String tipo = 'ME_GUSTA',
  }) {
    return ApiHelper.post(
      _client,
      ApiConstants.reacciones,
      body: {
        if (publicacionId != null) 'PublicacionId': publicacionId,
        if (comentarioId != null) 'ComentarioId': comentarioId,
        'Tipo': tipo,
      },
      fromJson: ResultadoReaccion.fromJson,
    );
  }
}


class SeguimientoService {
  final ApiClient _client;

  SeguimientoService(this._client);

  Future<SeguimientoEstado> getEstado(int usuarioId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.seguimientos}/estado/$usuarioId',
      fromJson: SeguimientoEstado.fromJson,
    );
  }


  Future<List<UsuarioResumen>> getSiguiendo(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.seguimientos}/siguiendo/$usuarioId',
      fromJson: UsuarioResumen.fromJson,
    );
  }


  Future<List<UsuarioResumen>> getSeguidores(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.seguimientos}/seguidores/$usuarioId',
      fromJson: UsuarioResumen.fromJson,
    );
  }

  Future<List<int>> getIdsSeguidos() async {
    final response = await _client.dio.get('${ApiConstants.seguimientos}/ids');
    final data = response.data;
    if (data is List) {
      return data.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
    }
    return [];
  }

  Future<SeguimientoEstado> seguir(int usuarioId) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.seguimientos}/$usuarioId',
      fromJson: SeguimientoEstado.fromJson,
    );
  }

  Future<SeguimientoEstado> dejarDeSeguir(int usuarioId) async {
    final response = await _client.dio.delete(
      '${ApiConstants.seguimientos}/$usuarioId',
    );
    final data = response.data;
    return SeguimientoEstado.fromJson(
      data is Map ? Map<String, dynamic>.from(data) : const {},
    );
  }
}


class GuardadoService {
  final ApiClient _client;

  GuardadoService(this._client);


  Future<bool> alternar(int publicacionId) async {
    final response = await _client.dio.post(
      '${ApiConstants.guardados}/$publicacionId',
    );
    final data = response.data;
    if (data is Map) return data['guardada'] == true;
    return false;
  }
}


class DenunciaService {
  final ApiClient _client;

  DenunciaService(this._client);

  Future<void> crear({
    int? publicacionId,
    int? comentarioId,
    required String motivo,
    String? descripcion,
  }) {
    return ApiHelper.postVoid(
      _client,
      ApiConstants.denuncias,
      body: {
        if (publicacionId != null) 'PublicacionId': publicacionId,
        if (comentarioId != null) 'ComentarioId': comentarioId,
        'Motivo': motivo,
        if (descripcion != null && descripcion.trim().isNotEmpty)
          'Descripcion': descripcion.trim(),
      },
    );
  }
}
