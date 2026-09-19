import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/challenge/challenge_models.dart';

class RetoService {
  final ApiClient _client;

  RetoService(this._client);

  Future<List<RetoResponse>> getRetos() {
    return ApiHelper.getList(
      _client,
      ApiConstants.retos,
      fromJson: RetoResponse.fromJson,
    );
  }

  Future<List<RetoResponse>> getRetosActivos() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.retos}/activos',
      fromJson: RetoResponse.fromJson,
    );
  }

  Future<RetoResponse> getRetoPorId(int id) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.retos}/$id',
      fromJson: RetoResponse.fromJson,
    );
  }

  /// Registra un reto del catálogo local en el backend (upsert por Codigo).
  /// Si ya existe con ese codigo, el servidor lo reutiliza y actualiza su
  /// recompensa (XP + Monedas Eco).
  Future<RetoResponse> registrarReto({
    required String codigo,
    required int categoriaId,
    required String titulo,
    required String descripcion,
    required String instrucciones,
    required int experienciaRecompensa,
    required int monedasRecompensa,
    required String dificultad,
  }) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.retos}/registrar',
      body: {
        'Codigo': codigo,
        'CategoriaId': categoriaId,
        'Titulo': titulo,
        'Descripcion': descripcion,
        'Instrucciones': instrucciones,
        'ExperienciaRecompensa': experienciaRecompensa,
        'MonedasRecompensa': monedasRecompensa,
        // Compatibilidad con backend anterior.
        'Puntos': experienciaRecompensa,
        'Dificultad': dificultad,
      },
      fromJson: RetoResponse.fromJson,
    );
  }

  /// Verifica (o crea) el reto en el backend y lo asigna al usuario en UNA
  /// sola llamada. El reto vive en `Retos`: si no existe por Codigo se crea;
  /// después se asegura la participación usuario↔reto y se aplica el estado.
  Future<UsuarioRetoResponse> asignarReto({
    required int usuarioId,
    required String codigo,
    required int categoriaId,
    required String titulo,
    required String descripcion,
    required String instrucciones,
    required int experienciaRecompensa,
    required int monedasRecompensa,
    required String dificultad,
    String estado = 'INICIADO',
    String? evidencia,
    int puntosObtenidos = 0,
  }) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.retos}/asignar',
      body: {
        'UsuarioId': usuarioId,
        'Codigo': codigo,
        'CategoriaId': categoriaId,
        'Titulo': titulo,
        'Descripcion': descripcion,
        'Instrucciones': instrucciones,
        'ExperienciaRecompensa': experienciaRecompensa,
        'MonedasRecompensa': monedasRecompensa,
        // Compatibilidad con backend anterior.
        'Puntos': experienciaRecompensa,
        'Dificultad': dificultad,
        'Estado': estado,
        'Evidencia': evidencia,
        'PuntosObtenidos': puntosObtenidos,
      },
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  Future<List<RetoResponse>> getRetosPorCategoria(int categoriaId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.retos}/categoria/$categoriaId',
      fromJson: RetoResponse.fromJson,
    );
  }

  Future<List<RetoResponse>> getRetosPorDificultad(String dificultad) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.retos}/dificultad/$dificultad',
      fromJson: RetoResponse.fromJson,
    );
  }

  Future<List<UsuarioRetoResponse>> getRetosUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/usuario/$usuarioId',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  /// Participación específica de un usuario en un reto (404 si no existe).
  Future<UsuarioRetoResponse> getRetoUsuario(int usuarioId, int retoId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.usuariosRetos}/usuario/$usuarioId/reto/$retoId',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  Future<List<UsuarioRetoResponse>> getRetosActivosUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/usuario/$usuarioId/activos',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  Future<List<UsuarioRetoResponse>> getRetosCompletadosUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosRetos}/usuario/$usuarioId/completados',
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  Future<UsuarioRetoResponse> registrarParticipacion(
    int usuarioId,
    int retoId,
  ) {
    return ApiHelper.post(
      _client,
      ApiConstants.usuariosRetos,
      body: {'UsuarioId': usuarioId, 'RetoId': retoId},
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  /// Sincroniza en UN solo viaje todos los retos del catálogo que el usuario
  /// ya completó o envió a revisión: crea los retos inexistentes (por Codigo)
  /// y asigna/actualiza la participación del usuario en uno solo.
  Future<List<UsuarioRetoResponse>> sincronizarParticipaciones(
    int usuarioId,
    List<Map<String, dynamic>> participaciones,
  ) {
    return ApiHelper.postList(
      _client,
      '${ApiConstants.usuariosRetos}/sincronizar',
      body: {'UsuarioId': usuarioId, 'Participaciones': participaciones},
      fromJson: UsuarioRetoResponse.fromJson,
    );
  }

  Future<void> actualizarEstado(int usuarioRetoId, String estado) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/estado',
      body: {'Estado': estado},
    );
  }

  Future<void> completarReto(int usuarioRetoId, int puntosObtenidos) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/completar',
      body: {'PuntosObtenidos': puntosObtenidos},
    );
  }

  Future<void> registrarEvidencia(int usuarioRetoId, String evidencia) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuariosRetos}/$usuarioRetoId/evidencia',
      body: {'Evidencia': evidencia},
    );
  }
}
