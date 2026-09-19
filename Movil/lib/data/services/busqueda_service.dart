import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../models/social/social_models.dart';

class BusquedaService {
  final ApiClient _client;

  BusquedaService(this._client);

  Future<ResultadoBusqueda> buscar(String termino, {int limite = 15}) {
    return ApiHelper.get(
      _client,
      ApiConstants.busqueda,
      queryParameters: {'q': termino, 'limite': limite},
      fromJson: ResultadoBusqueda.fromJson,
    );
  }


  Future<List<UsuarioResumen>> getUsuarios({
    int limite = 100,
    int? excluir,
  }) {
    return ApiHelper.getList(
      _client,
      '${ApiConstants.busqueda}/usuarios',
      queryParameters: {
        'limite': limite,
        if (excluir != null) 'excluir': excluir,
      },
      fromJson: UsuarioResumen.fromJson,
    );
  }
}
