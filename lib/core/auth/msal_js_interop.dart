import 'dart:js_interop';

import '../config/env_config.dart';

/// Dart interop bindings for MSAL.js functions defined in web/msal_interop.js
@JS('initMsal')
external JSPromise<JSString?> _initMsal(
  JSString clientId,
  JSString tenantId,
  JSString redirectUri,
);

@JS('msalLogin')
external JSPromise<JSAny?> _msalLogin(JSArray<JSString> scopes);

@JS('msalGetToken')
external JSPromise<JSString?> _msalGetToken(JSArray<JSString> scopes);

@JS('msalLogout')
external JSPromise<JSAny?> _msalLogout();

@JS('msalGetAccount')
external JSString? _msalGetAccount();

@JS('msalIsLoggedIn')
external JSBoolean _msalIsLoggedIn();

@JS('msalClearHash')
external void _msalClearHash();

/// MSAL.js wrapper for Flutter web
class MsalJsInterop {
  static JSArray<JSString> _scopesToJsArray(List<String> scopes) {
    return scopes.map((s) => s.toJS).toList().toJS;
  }

  /// Initializes the MSAL instance and returns an access token if a redirect
  /// sign-in completed successfully.
  static Future<String?> initialize() async {
    final result = await _initMsal(
      EnvConfig.azureClientId.toJS,
      EnvConfig.azureTenantId.toJS,
      EnvConfig.azureRedirectUri.toJS,
    ).toDart;
    // Clear the Azure AD redirect hash before GoRouter reads the URL.
    clearHash();
    return result?.toDart;
  }

  /// Clears the URL hash fragment left by Azure AD redirects.
  static void clearHash() => _msalClearHash();

  /// Starts redirect-based sign-in.
  static Future<void> loginRedirect() async {
    await _msalLogin(_scopesToJsArray(EnvConfig.azureScopes)).toDart;
  }

  /// Gets an access token, preferring silent acquisition first.
  static Future<String?> getAccessToken() async {
    final result =
        await _msalGetToken(_scopesToJsArray(EnvConfig.azureScopes)).toDart;
    return result?.toDart;
  }

  /// Starts sign-out.
  static Future<void> logout() async {
    await _msalLogout().toDart;
  }

  /// Returns the active account as JSON.
  static String? getAccountJson() {
    return _msalGetAccount()?.toDart;
  }

  /// Returns whether the app currently considers the user authenticated.
  static bool get isLoggedIn => _msalIsLoggedIn().toDart;
}
