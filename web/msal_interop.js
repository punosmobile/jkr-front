// MSAL.js interop for Flutter web
// Konfiguraatio tulee Dart-puolelta initMsal()-kutsulla

let msalInstance = null;

// Tallenna hash heti sivun latautuessa ennen kuin Flutter muuttaa sitä
const _savedHash = window.location.hash;

// Promise joka valmistuu kun MSAL on alustettu (estetään tuplaalustus)
let _msalInitPromise = null;

function initMsal(clientId, tenantId, redirectUri) {
  // Jos MSAL on jo alustettu tai alustumassa, palauta olemassa oleva promise
  if (_msalInitPromise) {
    console.log("[MSAL] Already initialized, returning existing promise");
    return _msalInitPromise;
  }

  if (typeof msal === "undefined") {
    console.error("MSAL.js library not loaded! Check CDN script in index.html.");
    return Promise.reject("MSAL.js not loaded");
  }

  const msalConfig = {
    auth: {
      clientId: clientId,
      authority: `https://login.microsoftonline.com/${tenantId}`,
      redirectUri: redirectUri,
      postLogoutRedirectUri: redirectUri,
      navigateToLoginRequestUrl: false,
    },
    cache: {
      cacheLocation: "localStorage",
      storeAuthStateInCookie: false,
    },
  };

  msalInstance = new msal.PublicClientApplication(msalConfig);

  // Palauta tallennettu hash URL:iin ennen handleRedirectPromise-kutsua
  // (Flutter path URL strategy saattaa poistaa sen ennen tätä)
  if (_savedHash && _savedHash.includes("code=")) {
    console.log("[MSAL] Restoring saved hash for redirect handling");
    window.location.hash = _savedHash;
  }

  // Käsittele redirect-vastaukset (v2:ssa ei tarvita initialize()-kutsua)
  _msalInitPromise = msalInstance.handleRedirectPromise().then(function (response) {
    console.log("[MSAL] handleRedirectPromise response:", response);
    if (response && response.account) {
      console.log("[MSAL] Redirect login onnistui, account:", response.account.username);
      msalInstance.setActiveAccount(response.account);
      return response.accessToken || "redirect_ok";
    }
    // Tarkista onko jo kirjautunut tili
    const accounts = msalInstance.getAllAccounts();
    console.log("[MSAL] Existing accounts count:", accounts.length, "accounts:", JSON.stringify(accounts.map(a => a.username)));
    if (accounts.length > 0) {
      msalInstance.setActiveAccount(accounts[0]);
      console.log("[MSAL] Set active account:", accounts[0].username);
    }
    return null;
  }).catch(function (error) {
    console.error("[MSAL] handleRedirectPromise error:", error);
    return null;
  });

  return _msalInitPromise;
}

function msalLogin(scopes) {
  if (!msalInstance) return Promise.reject("MSAL not initialized");

  const loginRequest = {
    scopes: scopes,
  };

  return msalInstance.loginRedirect(loginRequest);
}

function msalLoginPopup(scopes) {
  if (!msalInstance) return Promise.reject("MSAL not initialized");

  const loginRequest = {
    scopes: scopes,
  };

  return msalInstance.loginPopup(loginRequest).then(function (response) {
    msalInstance.setActiveAccount(response.account);
    return response.accessToken;
  });
}

function msalGetToken(scopes) {
  if (!msalInstance) return Promise.reject("MSAL not initialized");

  const account = msalInstance.getActiveAccount();
  if (!account) return Promise.reject("No active account");

  const silentRequest = {
    scopes: scopes,
    account: account,
  };

  return msalInstance
    .acquireTokenSilent(silentRequest)
    .then(function (response) {
      return response.accessToken;
    })
    .catch(function (error) {
      // Silent token acquisition failed, try interactive
      if (error instanceof msal.InteractionRequiredAuthError) {
        return msalInstance
          .acquireTokenPopup(silentRequest)
          .then(function (response) {
            return response.accessToken;
          });
      }
      throw error;
    });
}

function msalLogout() {
  if (!msalInstance) return Promise.resolve();
  return msalInstance.logoutRedirect();
}

function msalGetAccount() {
  if (!msalInstance) return null;
  const account = msalInstance.getActiveAccount();
  if (!account) return null;
  return JSON.stringify({
    name: account.name || "",
    username: account.username || "",
    localAccountId: account.localAccountId || "",
    tenantId: account.tenantId || "",
  });
}

function msalIsLoggedIn() {
  if (!msalInstance) {
    console.log("[MSAL] isLoggedIn: msalInstance is null");
    return false;
  }
  const account = msalInstance.getActiveAccount();
  const allAccounts = msalInstance.getAllAccounts();
  console.log("[MSAL] isLoggedIn check: activeAccount=", account, "allAccounts=", allAccounts.length);
  // Jos active account ei ole asetettu mutta tilejä on, aseta ensimmäinen
  if (!account && allAccounts.length > 0) {
    msalInstance.setActiveAccount(allAccounts[0]);
    console.log("[MSAL] isLoggedIn: auto-set active account:", allAccounts[0].username);
    return true;
  }
  return account !== null;
}

function msalClearHash() {
  // Puhdista Azure AD:n palauttama #code=... fragmentti URL:stä
  if (window.location.hash && window.location.hash.includes("code=")) {
    history.replaceState(null, "", window.location.pathname);
  }
}
