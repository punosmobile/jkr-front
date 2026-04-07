import 'dart:js_interop';

/// Ajonaikainen konfiguraatio-objekti, jonka nginx generoi
/// ympäristömuuttujista (runtime_config.js).
@JS('runtimeConfig')
external _RuntimeConfig? get _runtimeConfig;

extension type _RuntimeConfig._(JSObject _) implements JSObject {
  external String? get apiBaseUrl;
  external String? get azureClientId;
  external String? get azureTenantId;
  external String? get azureRedirectUri;
}

/// Palauttaa runtime-arvon jos saatavilla, muuten --dart-define-arvon.
/// Mahdollistaa saman Docker-imagen käytön kaikissa ympäristöissä.
String _resolve(String? runtimeValue, String dartDefineValue) {
  if (runtimeValue != null && runtimeValue.isNotEmpty) return runtimeValue;
  return dartDefineValue;
}

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

  static String get apiBaseUrl => _resolve(
    _runtimeConfig?.apiBaseUrl,
    const String.fromEnvironment('API_BASE_URL'),
  );

  static String get azureClientId => _resolve(
    _runtimeConfig?.azureClientId,
    const String.fromEnvironment('AZURE_CLIENT_ID'),
  );

  static String get azureTenantId => _resolve(
    _runtimeConfig?.azureTenantId,
    const String.fromEnvironment('AZURE_TENANT_ID'),
  );

  static String get azureRedirectUri => _resolve(
    _runtimeConfig?.azureRedirectUri,
    const String.fromEnvironment('AZURE_REDIRECT_URI'),
  );

  static String get azureAuthority =>
      'https://login.microsoftonline.com/$azureTenantId';

  static List<String> get azureScopes => [
    'api://$azureClientId/access_as_user',
  ];

  static bool get debugFeaturesEnabled => !Environment.isProduction;
  static Duration get apiTimeout => const Duration(seconds: 30);
}
