class AppConfig {
  const AppConfig._();
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const useRemoteApi = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: false,
  );
}
