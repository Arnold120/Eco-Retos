class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  String get userMessage {
    switch (statusCode) {
      case 400:
        return message.isNotEmpty ? message : 'Solicitud inválida';
      case 401:
        return 'Sesión expirada. Inicia sesión nuevamente';
      case 403:
        return 'No tienes permisos para realizar esta acción';
      case 404:
        return message.isNotEmpty ? message : 'Recurso no encontrado';
      case 409:
        return message.isNotEmpty ? message : 'Conflicto con los datos existentes';
      case 500:
        return 'Error del servidor. Intenta más tarde';
      default:
        return message.isNotEmpty ? message : 'Error inesperado';
    }
  }
}

class NetworkException extends ApiException {
  const NetworkException()
      : super(statusCode: 0, message: 'Sin conexión a internet');
}

class TimeoutException extends ApiException {
  const TimeoutException()
      : super(statusCode: 0, message: 'Tiempo de espera agotado');
}
