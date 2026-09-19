class EnvConfig {
  const EnvConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://guam-its-serious-exercise.trycloudflare.com/api',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isTesting => environment == 'testing';
  static bool get isProduction => environment == 'production';
}
