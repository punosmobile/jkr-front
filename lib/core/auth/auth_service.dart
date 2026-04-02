import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'msal_js_interop.dart';

/// Azure AD -autentikointipalvelu MSAL.js:n kautta (vain web).
@lazySingleton
class AuthService {
  String? _cachedToken;
  bool _initialized = false;

  /// Initialisoi MSAL. Kutsutaan kerran sovelluksen käynnistyksessä.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final token = await MsalJsInterop.initialize();
      if (token != null) {
        _cachedToken = token;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('MSAL initialization error: $e');
    }
  }

  /// Kirjaudu sisään Azure AD:lla (redirect-menetelmä)
  Future<bool> login() async {
    try {
      await MsalJsInterop.loginRedirect();
      // Redirect tapahtuu — tämä koodi ei jatku.
      // Token saadaan kun käyttäjä palaa takaisin (initialize käsittelee).
      return true;
    } catch (e) {
      debugPrint('Azure AD login error: $e');
      return false;
    }
  }

  /// Kirjaudu sisään popup-menetelmällä
  Future<bool> loginPopup() async {
    try {
      final token = await MsalJsInterop.loginPopup();
      _cachedToken = token;
      return token != null;
    } catch (e) {
      debugPrint('Azure AD login popup error: $e');
      return false;
    }
  }

  /// Kirjaudu ulos
  Future<void> logout() async {
    _cachedToken = null;
    await MsalJsInterop.logout();
  }

  /// Hae access token (silent ensin, sitten interactive)
  Future<String?> getAccessToken() async {
    try {
      final token = await MsalJsInterop.getAccessToken();
      _cachedToken = token;
      return token;
    } catch (e) {
      debugPrint('Azure AD getAccessToken error: $e');
      return null;
    }
  }

  /// Onko käyttäjä kirjautunut (synkroninen tarkistus)
  bool get isLoggedIn => MsalJsInterop.isLoggedIn;

  /// Hae viimeisin token synkronisesti (välimuistista)
  String? get cachedToken => _cachedToken;

  /// Hae käyttäjän tiedot JSON-muodossa
  String? get accountJson => MsalJsInterop.getAccountJson();
}
