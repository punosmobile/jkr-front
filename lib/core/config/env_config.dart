/// Environment configuration.
enum Environment {
  development,
  staging,
  production;
  
  static Environment get current {
    const envName = String.fromEnvironment('ENV', defaultValue: 'local');
    return switch (envName) {
      'prod' || 'production' => Environment.production,
      'staging' => Environment.staging,
      _ => Environment.development,
    };
  }
  
  static bool get isProduction => current == Environment.production;
  static bool get isDevelopment => current == Environment.development;
}

class EnvConfig {
  const EnvConfig._();
  
  // --dart-define tai oletusarvot
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  
  static const String azureClientId = String.fromEnvironment(
    'AZURE_CLIENT_ID',
  );
  
  static const String azureTenantId = String.fromEnvironment(
    'AZURE_TENANT_ID',
  );
  
  static String get azureAuthority =>
      'https://login.microsoftonline.com/$azureTenantId';
  
  static List<String> get azureScopes => [
    'api://$azureClientId/access_as_user',
  ];
  
  static const String azureRedirectUri = String.fromEnvironment(
    'AZURE_REDIRECT_URI',
  );
  
  static String get apiBaseUrl => _apiBaseUrl;
  
  static bool get debugFeaturesEnabled => !Environment.isProduction;
  static Duration get apiTimeout => const Duration(seconds: 30);
}
