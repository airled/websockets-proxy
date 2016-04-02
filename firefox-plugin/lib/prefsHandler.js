var preferences = require("sdk/simple-prefs");

function fetchPrefs() {
  return {
    wsaddress: preferences.prefs["Websocket address"],
    email: preferences.prefs["E-mail"],
    password: preferences.prefs["Password"],
    proxyaddress: preferences.prefs["Proxy address"],
    timeout: preferences.prefs["Reconnection timeout"],
    profile: preferences.prefs["Profile"],
    proxyProfile: preferences.prefs["Proxy profile"]
  };
}

function savePrefs(prefs) {
  preferences.prefs["Websocket address"] = prefs.wsaddress;
  preferences.prefs["E-mail"] = prefs.email;
  preferences.prefs["Password"] = prefs.password;
  preferences.prefs["Proxy address"] = prefs.proxyaddress;
  preferences.prefs["Reconnection timeout"] = prefs.timeout;
  preferences.prefs["Profile"] = prefs.profile;
  preferences.prefs["Proxy profile"] = prefs.proxyProfile;
}

exports.fetch = fetchPrefs;
exports.save = savePrefs;
