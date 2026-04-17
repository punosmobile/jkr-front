// MSAL.js interop for Flutter web
// Configuration is passed from Dart via initMsal().

let msalInstance = null;

const _logoutFlagKey = "jkr.logged_out";

// Capture the hash before Flutter modifies it.
const _savedHash = window.location.hash;

// Reuse a single initialization promise to avoid double initialization.
let _msalInitPromise = null;

function clearMsalStorage() {
  Object.keys(localStorage).forEach(function(key) {
    const normalized = key.toLowerCase();
    if (normalized.includes("msal") ||
        normalized.includes("login.microsoftonline") ||
        normalized.includes("accesstoken") ||
        normalized.includes("idtoken") ||
        normalized.includes("refreshtoken")) {
      localStorage.removeItem(key);
    }
  });
}

function initMsal(clientId, tenantId, redirectUri) {
  if (_msalInitPromise) {
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

  // Restore the saved hash before handleRedirectPromise().
  if (_savedHash && _savedHash.includes("code=")) {
    window.location.hash = _savedHash;
  }

  _msalInitPromise = msalInstance.handleRedirectPromise().then(function (response) {
    // If the user explicitly logged out of the app, suppress automatic
    // sign-in restoration until they press the login button again.
    if (localStorage.getItem(_logoutFlagKey) && !response) {
      msalInstance.setActiveAccount(null);
      clearMsalStorage();
      return null;
    }

    if (response && response.account) {
      msalInstance.setActiveAccount(response.account);
      return response.accessToken || null;
    }
    const accounts = msalInstance.getAllAccounts();
    if (accounts.length > 0) {
      msalInstance.setActiveAccount(accounts[0]);
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

  localStorage.removeItem(_logoutFlagKey);

  const loginRequest = {
    scopes: scopes,
  };

  return msalInstance.loginRedirect(loginRequest);
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
      // Fall back to an interactive popup only when silent acquisition is not
      // possible for the current browser session.
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

  // Prevent the next app startup from restoring the session automatically.
  localStorage.setItem(_logoutFlagKey, "true");
  msalInstance.setActiveAccount(null);
  _msalInitPromise = null;

  const account = msalInstance.getAllAccounts()[0];
  return msalInstance.logoutRedirect({
    account: account || undefined,
  });
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
  if (!msalInstance) return false;
  if (localStorage.getItem(_logoutFlagKey)) return false;

  const account = msalInstance.getActiveAccount();
  const allAccounts = msalInstance.getAllAccounts();

  if (!account && allAccounts.length > 0) {
    msalInstance.setActiveAccount(allAccounts[0]);
    return true;
  }

  return account !== null;
}

function msalClearHash() {
  // Remove the Azure AD #code=... fragment from the URL.
  if (window.location.hash && window.location.hash.includes("code=")) {
    history.replaceState(null, "", window.location.pathname);
  }
}
