import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';


class AccountService {
  final ApiClient _client;

  AccountService(this._client);

  Future<void> actualizarCuenta(
    int usuarioId, {
    required String nombreUsuario,
    required String correo,
  }) {
    return ApiHelper.putVoid(
      _client,
      '${ApiConstants.usuarios}/$usuarioId',
      body: {
        'NombreUsuario': nombreUsuario,
        'Correo': correo,
      },
    );
  }

  Future<void> cambiarContrasena(
    int usuarioId, {
    required String actual,
    required String nueva,
  }) {
    return ApiHelper.patchVoid(
      _client,
      '${ApiConstants.usuarios}/$usuarioId/contrasena',
      body: {
        'ContrasenaActual': actual,
        'NuevaContrasena': nueva,
      },
    );
  }

  Future<void> desactivarMiCuenta(String contrasena) {
    return ApiHelper.postVoid(
      _client,
      '${ApiConstants.usuarios}/mi-cuenta/desactivar',
      body: {'Contrasena': contrasena},
    );
  }
}
