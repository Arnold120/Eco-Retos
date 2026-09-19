import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../../core/network/api_exception.dart';
import '../models/gamification/gamification_models.dart';

class ProgresoService {
  final ApiClient _client;

  ProgresoService(this._client);

  Future<ProgresoResponse> getProgreso(int usuarioId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.progresos}/usuario/$usuarioId',
      fromJson: ProgresoResponse.fromJson,
    );
  }

  Future<List<RankingItem>> getRanking(int cantidad) async {
    final response = await _client.dio
        .get('${ApiConstants.progresos}/ranking/$cantidad');
    final data = response.data as List;
    return data.asMap().entries.map((entry) {
      final item = entry.value;
      return RankingItem(
        position: entry.key + 1,
        nombreUsuario: item['nombreUsuario']?.toString() ?? '',
        puntos: item['puntos'] ?? 0,
        nivel: item['nivel'] ?? 1,
      );
    }).toList();
  }

  Future<void> incrementarRetos(int usuarioId) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.progresos}/usuario/$usuarioId/retos',
    );
  }

  Future<void> incrementarTrivias(int usuarioId) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.progresos}/usuario/$usuarioId/trivias',
    );
  }

  Future<void> incrementarInsignias(int usuarioId) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.progresos}/usuario/$usuarioId/insignias',
    );
  }

  Future<void> incrementarPublicaciones(int usuarioId) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.progresos}/usuario/$usuarioId/publicaciones',
    );
  }
}

class JardinService {
  final ApiClient _client;

  JardinService(this._client);

  Future<JardinResponse> getJardin(int usuarioId) async {
    try {
      return await ApiHelper.get(
        _client,
        '${ApiConstants.jardines}/usuario/$usuarioId',
        fromJson: JardinResponse.fromJson,
      );
    } on ApiException catch (e) {
      // Si el usuario no tiene jardín (404), devolvemos uno vacío por defecto
      if (e.statusCode == 404) {
        return JardinResponse(
          jardinId: 0,
          usuarioId: usuarioId,
          nivelJardin: 1,
          plantas: 0,
          arboles: 0,
          flores: 0,
          puntosJardin: 0,
        );
      }
      rethrow;
    }
  }

  Future<void> actualizarJardin(int usuarioId, JardinResponse jardin) {
    return ApiHelper.put(
      _client,
      '${ApiConstants.jardines}/usuario/$usuarioId',
      body: {
        'NivelJardin': jardin.nivelJardin,
        'Plantas': jardin.plantas,
        'Arboles': jardin.arboles,
        'Flores': jardin.flores,
        'PuntosJardin': jardin.puntosJardin,
      },
      fromJson: (_) {},
    );
  }

  Future<void> agregarPuntos(int usuarioId, int puntos) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.jardines}/usuario/$usuarioId/puntos',
      body: {'PuntosJardin': puntos},
    );
  }
}

class InsigniaService {
  final ApiClient _client;

  InsigniaService(this._client);

  Future<List<InsigniaResponse>> getInsignias() {
    return ApiHelper.getList(
      _client,
      ApiConstants.insignias,
      fromJson: InsigniaResponse.fromJson,
    );
  }

  Future<List<UsuarioInsigniaResponse>> getInsigniasUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.usuariosInsignias}/usuario/$usuarioId',
      fromJson: UsuarioInsigniaResponse.fromJson,
    );
  }

  Future<void> otorgarInsignia(int usuarioId, int insigniaId) {
    return ApiHelper.postVoid(
      _client,
      ApiConstants.usuariosInsignias,
      body: {
        'UsuarioId': usuarioId,
        'InsigniaId': insigniaId,
      },
    );
  }
}

/// Servicio del Monedero: única fuente de verdad del saldo de Monedas Eco.
///
/// - getSaldo: saldo actual + XP/nivel (el backend calcula todo).
/// - getHistorial: auditoría de movimientos (ganancias y gastos).
/// - reclamarRecompensa: el backend calcula la XP y las monedas y es idempotente.
/// - gastar: gasta monedas validando el saldo en el servidor.
class MonederoService {
  final ApiClient _client;

  MonederoService(this._client);

  Future<SaldoMonederoResponse> getSaldo() {
    return ApiHelper.get(
      _client,
      '${ApiConstants.monedero}/saldo',
      fromJson: SaldoMonederoResponse.fromJson,
    );
  }

  Future<List<MovimientoMonedaResponse>> getHistorial({int? cantidad}) {
    final consulta =
        (cantidad != null && cantidad > 0) ? '?cantidad=$cantidad' : '';
    return ApiHelper.getList(
      _client,
      '${ApiConstants.monedero}/historial$consulta',
      fromJson: MovimientoMonedaResponse.fromJson,
    );
  }

  Future<List<CategoriaMonedas>> getPorCategoria() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.monedero}/historial/por-categoria',
      fromJson: CategoriaMonedas.fromJson,
    );
  }

  /// Reclama una recompensa (TRIVIA, TRIVIA_SEMANA, RETO o INSIGNIA).
  /// La cantidad de XP/monedas la decide el backend.
  Future<RecompensaResponse> reclamarRecompensa({
    required String tipo,
    required String claveIdempotencia,
    int? categoriaId,
    int? puntuacion,
    int? totalPreguntas,
    int? retoId,
    int? insigniaId,
    String? descripcion,
  }) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.monedero}/recompensa',
      body: {
        'Tipo': tipo,
        'ClaveIdempotencia': claveIdempotencia,
        'CategoriaId': categoriaId,
        'Puntuacion': puntuacion,
        'TotalPreguntas': totalPreguntas,
        'RetoId': retoId,
        'InsigniaId': insigniaId,
        'Descripcion': descripcion,
      },
      fromJson: RecompensaResponse.fromJson,
    );
  }

  /// Gasta Monedas Eco (herramientas del jardín, ayudas de trivia, etc.).
  Future<GastoMonedasResponse> gastar({
    required int cantidad,
    required String tipo,
    required String descripcion,
    int? categoriaId,
    String? claveIdempotencia,
  }) {
    return ApiHelper.post(
      _client,
      '${ApiConstants.monedero}/gastar',
      body: {
        'Cantidad': cantidad,
        'Tipo': tipo,
        'Descripcion': descripcion,
        'CategoriaId': categoriaId,
        'ClaveIdempotencia': claveIdempotencia,
      },
      fromJson: GastoMonedasResponse.fromJson,
    );
  }
}

class RachaService {
  final ApiClient _client;

  RachaService(this._client);

  Future<RachaResponse> registrarAcceso(int usuarioId) {
    return ApiHelper.post(
      _client,
      ApiConstants.rachas,
      body: {'UsuarioId': usuarioId},
      fromJson: RachaResponse.fromJson,
    );
  }

  Future<int> getRachaActual(int usuarioId) async {
    final response = await _client.dio
        .get('${ApiConstants.rachas}/usuario/$usuarioId/actual');
    return response.data['racha'] ?? 0;
  }

  Future<List<RachaResponse>> getHistorialRachas(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.rachas}/usuario/$usuarioId',
      fromJson: RachaResponse.fromJson,
    );
  }
}
