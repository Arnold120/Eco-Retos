import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        emit(const AuthUnauthenticated());
        return;
      }

      if (JwtDecoder.isExpired(token)) {
        await _authService.clearSession();
        emit(const AuthUnauthenticated());
        return;
      }

      final decoded = JwtDecoder.decode(token);
      // Los claims del backend .NET usan URIs largas; se buscan por
      // fragmento para no depender del nombre exacto.
      final usuarioId =
          int.tryParse(AuthCubit.claimDelToken(decoded, const [
                'nameidentifier',
                'nameid',
                'sub',
              ]) ??
              '') ??
          0;
      final nombreUsuario = AuthCubit.claimDelToken(decoded, const [
            'unique_name',
            '/name',
          ]) ??
          '';
      final correo = AuthCubit.claimDelToken(decoded, const [
            'emailaddress',
            'email',
          ]) ??
          '';

      if (usuarioId == 0) {
        emit(const AuthUnauthenticated());
        return;
      }

      // Roles persistentes de la sesión; si faltan, se intentan leer del JWT.
      var roles = await _authService.getRoles();
      if (roles.isEmpty) roles = AuthCubit.rolesDelToken(decoded);

      emit(
        Authenticated(
          usuarioId: usuarioId,
          nombreUsuario: nombreUsuario,
          correo: correo,
          token: token,
          nivel: 1,
          totalPuntos: 0,
          roles: roles,
        ),
      );
    } catch (e) {
      await _authService.clearSession();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String correo, String contrasena) async {
    emit(const AuthLoading());
    try {
      final response = await _authService.login(correo, contrasena);

      emit(
        Authenticated(
          usuarioId: response.usuario.usuarioId,
          nombreUsuario: response.usuario.nombreUsuario,
          correo: response.usuario.correo,
          token: response.token,
          nivel: 1,
          totalPuntos: 0,
          roles: response.usuario.roles,
        ),
      );
    } catch (e) {
      final status = _statusDe(e);
      String message;
      if (status == 401) {
        message = 'Credenciales no válidas. Revisa tu correo y contraseña.';
      } else if (e is ApiException && e.message.isNotEmpty) {
        message = e.message;
      } else if (status == 0) {
        message = 'Sin conexión a internet';
      } else {
        message = 'No pudimos iniciar sesión. Inténtalo nuevamente.';
      }
      emit(AuthError(message));
      emit(const AuthUnauthenticated());
    }
  }

  /// Extrae el codigo HTTP del error de red sin depender del tipo concreto.
  static int _statusDe(Object error) {
    if (error is ApiException) return error.statusCode;
    final coincidencia = RegExp(r'\b(400|401|403|404|409|500)\b')
        .firstMatch(error.toString());
    return coincidencia == null ? 0 : int.parse(coincidencia.group(1)!);
  }

  Future<void> register({
    required String nombreUsuario,
    required String correo,
    required String contrasena,
  }) async {
    emit(const AuthLoading());
    try {
      final response = await _authService.register(
        nombreUsuario: nombreUsuario,
        correo: correo,
        contrasena: contrasena,
      );

      emit(
        AuthRegistrationSuccess(
          usuarioId: response.usuario.usuarioId,
          nombre: response.usuario.nombreUsuario,
          correo: response.usuario.correo,
          token: response.token,
        ),
      );

      emit(
        Authenticated(
          usuarioId: response.usuario.usuarioId,
          nombreUsuario: response.usuario.nombreUsuario,
          correo: response.usuario.correo,
          token: response.token,
          nivel: 1,
          totalPuntos: 0,
          roles: response.usuario.roles,
        ),
      );
    } catch (e) {
      String message = 'Error al crear la cuenta';
      if (e.toString().contains('409') || e.toString().contains('registrado')) {
        message = 'El correo ya está registrado';
      } else if (e.toString().contains('nombre')) {
        message = 'El nombre de usuario ya está en uso';
      }
      emit(AuthError(message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _authService.clearSession();
    emit(const AuthUnauthenticated());
  }

  /// Busca un claim por fragmento de clave (los claims de .NET vienen como
  /// URIs largas: ".../claims/nameidentifier", ".../claims/name", etc.).
  static String? claimDelToken(
    Map<String, dynamic> decoded,
    List<String> fragmentos,
  ) {
    for (final fragmento in fragmentos) {
      for (final entry in decoded.entries) {
        final clave = entry.key.toLowerCase();
        if (clave.endsWith(fragmento) || clave == fragmento) {
          final valor = entry.value;
          if (valor == null) continue;
          if (valor is List && valor.isNotEmpty) return valor.first.toString();
          return valor.toString();
        }
      }
    }
    return null;
  }

  /// El claim `role` del JWT puede venir como string único o lista.
  static List<String> rolesDe(Object? claim) {
    if (claim == null) return const [];
    if (claim is List) return claim.map((e) => e.toString()).toList();
    return [claim.toString()];
  }

  /// Localiza el rol del payload del JWT sin depender del nombre exacto
  /// del claim ("role", "roles", URI completa de los claims de Windows...).
  static List<String> rolesDelToken(Map<String, dynamic> decoded) {
    for (final entry in decoded.entries) {
      if (entry.key.toLowerCase().contains('role')) {
        return rolesDe(entry.value);
      }
    }
    return const [];
  }
}
