import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env_config.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _tokenExpiryKey = 'token_expiry';

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            ) {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(_AuthInterceptor(_storage));
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> saveTokenExpiry(DateTime expiry) =>
      _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _tokenExpiryKey);
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) return false;
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry == null) return false;
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      debugPrint('ApiClient.hasValidToken error: $e');
      return false;
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      handler.next(err);
      return;
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: const TimeoutException(),
      ));
      return;
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: const NetworkException(),
      ));
      return;
    }

    handler.next(err);
  }
}
