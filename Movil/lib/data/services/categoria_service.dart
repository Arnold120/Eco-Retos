import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/challenge/challenge_models.dart';

class CategoriaService {
  final ApiClient _client;

  CategoriaService(this._client);

  Future<List<CategoriaResponse>> getCategorias() {
    return ApiHelper.getList(
      _client,
      ApiConstants.categorias,
      fromJson: CategoriaResponse.fromJson,
    );
  }

  Future<CategoriaResponse> getCategoriaPorId(int id) {
    return ApiHelper.get(
      _client,
      '${ApiConstants.categorias}/$id',
      fromJson: CategoriaResponse.fromJson,
    );
  }
}
