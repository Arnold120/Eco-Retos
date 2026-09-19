import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import '../network/api_client.dart';

class ApiHelper {
  const ApiHelper._();

  static Future<T> get<T>(
    ApiClient client,
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final response = await client.dio.get(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<List<T>> getList<T>(
    ApiClient client,
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final response = await client.dio.get(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is List) {
        return data.map((e) => fromJson(_asMap(e))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<T> post<T>(
    ApiClient client,
    String path, {
    dynamic body,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final response = await client.dio.post(path, data: body);
      return fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<List<T>> postList<T>(
    ApiClient client,
    String path, {
    dynamic body,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final response = await client.dio.post(path, data: body);
      final data = response.data;
      if (data is List) {
        return data.map((e) => fromJson(_asMap(e))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<void> postVoid(
    ApiClient client,
    String path, {
    dynamic body,
  }) async {
    try {
      await client.dio.post(path, data: body);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<T> put<T>(
    ApiClient client,
    String path, {
    dynamic body,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final response = await client.dio.put(path, data: body);
      return fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<void> putVoid(
    ApiClient client,
    String path, {
    dynamic body,
  }) async {
    try {
      await client.dio.put(path, data: body);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<T> patch<T>(
    ApiClient client,
    String path, {
    dynamic body,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final response = await client.dio.patch(path, data: body);
      return fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<void> patchVoid(
    ApiClient client,
    String path, {
    dynamic body,
  }) async {
    try {
      await client.dio.patch(path, data: body);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<void> delete(ApiClient client, String path) async {
    try {
      await client.dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static ApiException _handleDioError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;

    final statusCode = e.response?.statusCode ?? 0;
    String message = '';

    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['mensaje']?.toString() ?? '';
      } else if (data is String) {
        message = data;
      }
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      data: e.response?.data,
    );
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }
}
