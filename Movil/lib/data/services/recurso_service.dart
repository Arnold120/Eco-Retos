import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/content/content_models.dart';

class RecursoService {
  final ApiClient _client;

  RecursoService(this._client);

  Future<List<RecursoResponse>> getRecursos() {
    return ApiHelper.getList(
      _client,
      ApiConstants.recursos,
      fromJson: RecursoResponse.fromJson,
    );
  }

  Future<List<RecursoResponse>> getRecursosActivos() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.recursos}/activos',
      fromJson: RecursoResponse.fromJson,
    );
  }

  Future<List<RecursoResponse>> getRecursosPorCategoria(int categoriaId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.recursos}/categoria/$categoriaId',
      fromJson: RecursoResponse.fromJson,
    );
  }

  Future<List<RecursoResponse>> getRecursosPorTipo(String tipo) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.recursos}/tipo/$tipo',
      fromJson: RecursoResponse.fromJson,
    );
  }
}

class MaterialService {
  final ApiClient _client;

  MaterialService(this._client);

  Future<List<MaterialResponse>> getMateriales() {
    return ApiHelper.getList(
      _client,
      ApiConstants.materiales,
      fromJson: MaterialResponse.fromJson,
    );
  }

  Future<List<MaterialResponse>> getMaterialesDisponibles() {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.materiales}/disponibles',
      fromJson: MaterialResponse.fromJson,
    );
  }
}

class InventarioService {
  final ApiClient _client;

  InventarioService(this._client);

  Future<List<InventarioResponse>> getInventarioUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.inventario}/usuario/$usuarioId',
      fromJson: InventarioResponse.fromJson,
    );
  }

  Future<InventarioResponse> getPorMaterial(int usuarioId, int materialId) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.inventario}/usuario/$usuarioId/material/$materialId',
      fromJson: InventarioResponse.fromJson,
    );
  }

  Future<InventarioResponse> agregarMaterial(
      int usuarioId, int materialId, int cantidad) {
    return ApiHelper.post(
      _client,
      ApiConstants.inventario,
      body: {
        'UsuarioId': usuarioId,
        'MaterialId': materialId,
        'Cantidad': cantidad,
      },
      fromJson: InventarioResponse.fromJson,
    );
  }

  Future<void> actualizarCantidad(int inventarioId, int cantidad) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.inventario}/$inventarioId/cantidad',
      body: {'Cantidad': cantidad},
    );
  }

  Future<void> quitarMaterial(int usuarioId, int materialId) {
    return ApiHelper.delete(
      _client,
      '${ApiConstants.inventario}/usuario/$usuarioId/material/$materialId',
    );
  }
}

class CompraService {
  final ApiClient _client;

  CompraService(this._client);

  /// Compra transaccional: el backend valida stock y saldo, cobra del
  /// Monedero, actualiza inventario y registra el movimiento. El usuario sale
  /// del token; el precio, del catálogo del servidor.
  Future<CompraResponse> createCompra({
    required List<DetalleCompraItem> detalles,
    String? claveIdempotencia,
  }) {
    return ApiHelper.post(
      _client,
      ApiConstants.compras,
      body: {
        'ClaveIdempotencia': claveIdempotencia,
        'Detalles': detalles.map((d) => d.toJson()).toList(),
      },
      fromJson: CompraResponse.fromJson,
    );
  }

  Future<List<CompraResponse>> getComprasUsuario(int usuarioId) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.compras}/usuario/$usuarioId',
      fromJson: CompraResponse.fromJson,
    );
  }
}
