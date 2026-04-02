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

@JS('msalLoginPopup')
external JSPromise<JSString?> _msalLoginPopup(JSArray<JSString> scopes);

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

  /// Initialisoi MSAL-instanssi. Palauttaa access tokenin jos redirect-login onnistui.
  static Future<String?> initialize() async {
    final result = await _initMsal(
      EnvConfig.azureClientId.toJS,
      EnvConfig.azureTenantId.toJS,
      EnvConfig.azureRedirectUri.toJS,
    ).toDart;
    // Puhdista Azure AD:n #code=... fragmentti URL:stä ennen GoRouteria
    clearHash();
    return result?.toDart;
  }

  /// Puhdista URL hash-fragmentti (Azure AD redirect jättää #code=...)
  static void clearHash() => _msalClearHash();

  /// Kirjaudu redirect-menetelmällä (sivu ohjautuu Microsoftille)
  static Future<void> loginRedirect() async {
    await _msalLogin(_scopesToJsArray(EnvConfig.azureScopes)).toDart;
  }

  /// Kirjaudu popup-menetelmällä. Palauttaa access tokenin.
  static Future<String?> loginPopup() async {
    final result =
        await _msalLoginPopup(_scopesToJsArray(EnvConfig.azureScopes)).toDart;
    return result?.toDart;
  }

  /// Hae access token (silent ensin, sitten interactive)
  static Future<String?> getAccessToken() async {
    final result =
        await _msalGetToken(_scopesToJsArray(EnvConfig.azureScopes)).toDart;
    return result?.toDart;
  }

  /// Kirjaudu ulos
  static Future<void> logout() async {
    await _msalLogout().toDart;
  }

  /// Hae aktiivisen käyttäjän tiedot JSON-muodossa
  static String? getAccountJson() {
    return _msalGetAccount()?.toDart;
  }

  /// Onko kirjautunut
  static bool get isLoggedIn => _msalIsLoggedIn().toDart;
}
