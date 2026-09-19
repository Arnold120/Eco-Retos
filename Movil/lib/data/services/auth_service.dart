import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/auth/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  static const String _rolesKey = 'auth_roles';

  ApiClient get apiClient => _apiClient;

  AuthService(this._apiClient)
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  Future<String?> getToken() async => _storage.read(key: 'auth_token');


  Future<List<String>> getRoles() async {
    try {
      final raw = await _storage.read(key: _rolesKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
    return const [];
  }

  Future<void> _saveRoles(List<String> roles) async {
    try {
      await _storage.write(key: _rolesKey, value: jsonEncode(roles));
    } catch (_) {}
  }

  Future<void> _saveToken(String token) async =>
      _storage.write(key: 'auth_token', value: token);

  Future<void> clearSession() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: _rolesKey);
    await _apiClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    if (JwtDecoder.isExpired(token)) {
      await clearSession();
      return false;
    }
    return true;
  }

  Future<AuthResponse> login(String correo, String contrasena) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.auth}/login',
        data: LoginRequest(correo: correo, contrasena: contrasena).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveToken(authResponse.token);
      await _apiClient.saveToken(authResponse.token);
      if (authResponse.expiraEn != null) {
        await _apiClient.saveTokenExpiry(authResponse.expiraEn!);
      }
      await _saveRoles(authResponse.usuario.roles);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String nombreUsuario,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.auth}/registrar',
        data: RegistroRequest(
          nombreUsuario: nombreUsuario,
          correo: correo,
          contrasena: contrasena,
        ).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveToken(authResponse.token);
      await _apiClient.saveToken(authResponse.token);
      if (authResponse.expiraEn != null) {
        await _apiClient.saveTokenExpiry(authResponse.expiraEn!);
      }
      await _saveRoles(authResponse.usuario.roles);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }
}
