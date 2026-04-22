import 'dart:js_interop';

import 'package:flutter/material.dart';

/// Ajonaikainen konfiguraatio-objekti, jonka nginx generoi
/// ympäristömuuttujista (runtime_config.js).
@JS('runtimeConfig')
external _RuntimeConfig? get _runtimeConfig;

extension type _RuntimeConfig._(JSObject _) implements JSObject {
  external String? get apiBaseUrl;
  external String? get azureClientId;
  external String? get azureTenantId;
  external String? get azureRedirectUri;
  external String? get env;
}

/// Palauttaa runtime-arvon jos saatavilla, muuten --dart-define-arvon.
/// Mahdollistaa saman Docker-imagen käytön kaikissa ympäristöissä.
String _resolve(String? runtimeValue, String dartDefineValue) {
  if (runtimeValue != null && runtimeValue.isNotEmpty) return runtimeValue;
  return dartDefineValue;
}

/// Environment configuration.
enum Environment {
  development(
    label: 'Kehitys',
    color: Color.fromARGB(255, 255, 106, 19), // Radiomasto
  ),
  test(
    label: 'Testi',
    color: Color.fromARGB(255, 242, 199, 92), // Ohra
  ),
  production(
    label: 'Tuotanto',
    color: Color.fromARGB(255, 0, 79, 113), // Vesijärven sininen
  );

  final String label;
  final Color color;

  const Environment({required this.label, required this.color});

  static Environment get current {
    final runtimeEnv = _runtimeConfig?.env;
    final envName = (runtimeEnv != null && runtimeEnv.isNotEmpty)
        ? runtimeEnv
        : const String.fromEnvironment('ENV', defaultValue: 'dev');
    return switch (envName) {
      'prod' || 'production' => Environment.production,
      'test' || 'staging' => Environment.test,
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
