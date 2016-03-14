var notification = require("sdk/notifications"),
    { ToggleButton } = require("sdk/ui/button/toggle"),
    panels = require("sdk/panel"),
    preferences = require("sdk/simple-prefs"),
    storage = require("sdk/simple-storage").storage,
    browserConfig = require("sdk/preferences/service"),
    self = require("sdk/self");

var wsState = "off";
var proxyState = storage.proxyState;

var button = ToggleButton({
  id: "bproxy",
  label: "BProxy",
  icon: {
    "16": "./16.png",
    "32": "./32.png",
    "64": "./64.png"
  },
  badge: "",
  onChange: handleButtonChange
});

var buttonPanel = panels.Panel({
  width: 170,
  height: 70,
  contentURL: self.data.url("button_panel/button_panel.html"),
  contentScriptFile: "./button_panel/button_panel.js",
  onHide: handleButtonPanelHide
});

if (proxyState === "on") {
  setBadge("p", "#0000EE");
  buttonPanel.port.emit("proxyStateIs", "on");
}
else {
  buttonPanel.port.emit("proxyStateIs", "off");
}

var prefsPanel = panels.Panel({
  width: 340,
  height: 275,
  contentURL: self.data.url("prefs_panel/prefs_panel.html"),
  contentScriptFile: "./prefs_panel/prefs_panel.js"
});

function fetchPrefs() {
  return {
    wsaddress: preferences.prefs["Websocket-address"],
    email: preferences.prefs["E-mail"],
    password: preferences.prefs["Password"],
    proxyaddress: preferences.prefs["Proxy address"],
    timeout: preferences.prefs["Reconnection timeout"]
  };
}

function handleButtonChange(state) {
  if (state.checked) {
    buttonPanel.show({
      position: button
    });
  }
}

function handleButtonPanelHide() {
  button.state("window", {checked: false});
}

function wsSwitch() {
  if (wsState === "off") {

    let prefs = fetchPrefs();
    if (prefs.wsaddress === "" || prefs.email === "" || prefs.password === "") {
      notify("Some fields are empty");
      return;
    }

    wsState = "on";

    buttonPanel.port.emit("wsStateIs", "on");
    pageWorker = require("sdk/page-worker").Page({
      contentScriptFile: "./pageworker_script.js"
    });

    pageWorker.port.emit("init", prefs);
    
    pageWorker.port.on("badge", function(pair) {
      setBadge(pair.value, pair.color);
    });

    pageWorker.port.on("notificate", function(message) {
      notify(message);
    });

    pageWorker.port.on("reconnect", function(message) {
      pageWorker.port.emit("init", fetchPrefs());
    });
    
    pageWorker.port.on("request", function(request) {
      var data = JSON.parse(request);
      var request = require("sdk/request").Request({
        url: data.url,
        headers: {
          "User-Agent": data.agent,
          "Referer": data.referer,
          "Cookie": data.cookies
        },
        content: data.query,
        anonymous: true,
        onComplete: function(response) {
          var responseData = {
            cookies: response.headers["Set-Cookie"],
            type: response.headers["Content-Type"],
            text: response.text,
            reply_to: data.reply_to
          };
          var responseJson = JSON.stringify(responseData);
          pageWorker.port.emit("response", responseJson);
        }
      });
      switch (data.method) {
        case "GET":
          request.get();
          break;
        case "POST":
          request.post();
          break;
        case "PUT":
          request.put();
          break;
        case "DELETE":
          request.delete();
          break;
        case "HEAD":
          request.head();
          break;
      }
    });
  }
  else {
    wsState = "off";
    buttonPanel.port.emit("wsStateIs", "off");
    pageWorker.destroy();
    notify("Locally closed");
    setBadge("", "");
  }
}

prefsPanel.port.on("close", function(msg) {
  prefsPanel.hide();
});

prefsPanel.port.on("saveprefs", function(prefs) {
  preferences.prefs["Websocket-address"] = prefs.wsaddress;
  preferences.prefs["E-mail"] = prefs.email;
  preferences.prefs["Password"] = prefs.password;
  preferences.prefs["Proxy address"] = prefs.proxyaddress;
  preferences.prefs["Reconnection timeout"] = prefs.timeout;
});

buttonPanel.port.on("pluginMenuClick", function(title) {
  switch (title) {
    case "ws":
      wsSwitch();
      break;
    case "proxy":
      switchProxyState();
      break;
    case "prefs":
      prefsPanel.port.emit("setprefs", fetchPrefs());
      prefsPanel.show();
      break;
  }
});

function switchProxyState(){
  let proxyaddress = fetchPrefs().proxyaddress;
  if (proxyaddress === "") {
    notify("Proxy address is empty");
    return;    
  }
  else{
    proxyIp = proxyaddress.replace("http://", "").split(":")[0];
    proxyPort = parseInt(proxyaddress.replace("http://", "").split(":")[1], 10);
  }
  if (proxyState != "on") {
    storage.proxyState = "on";
    proxyState = "on";
    buttonPanel.port.emit("proxyStateIs", "on");
    setBadge("p", "#0000EE");
    saveCurrentBrowserSettings();
    setConfig("network.proxy.type", 1);
    setConfig("network.proxy.http", proxyIp);
    setConfig("network.proxy.http_port", proxyPort);
    setConfig("network.proxy.no_proxies_on", "localhost, 127.0.0.1");
  }
  else {
    storage.proxyState = "off";
    proxyState = "off";
    buttonPanel.port.emit("proxyStateIs", "off");
    setBadge("", "");
    if (typeof storage.old == "undefined" || isEmpty(storage.old)) {
      resetBrowserSettings();
    }
    else {
      restoreOldBrowserSettings();
    }
  }
}

function setBadge(char, color){
  button.badge = char;
  button.badgeColor = color;
}

function setConfig(name, value) {
  browserConfig.set(name, value);
}

function saveCurrentBrowserSettings() {
  storage.old = {
    type: browserConfig.get('network.proxy.type'),
    http: browserConfig.get('network.proxy.http'),
    port: browserConfig.get('network.proxy.http_port'),
    no:   browserConfig.get('network.proxy.no_proxies_on')
  }
}

function restoreOldBrowserSettings() {
  setConfig("network.proxy.type", storage.old.type);
  setConfig("network.proxy.http", storage.old.http);
  setConfig("network.proxy.http_port", storage.old.port);
  setConfig("network.proxy.no_proxies_on", storage.old.no);
  delete storage.old;
}

function resetBrowserSettings() {
  browserConfig.reset("network.proxy.type");
  browserConfig.reset("network.proxy.http");
  browserConfig.reset("network.proxy.http_port");
  browserConfig.reset("network.proxy.no_proxies_on");
}

function isEmpty(obj) {
  for (let prop in obj) { 
    if (obj.hasOwnProperty(prop)) { 
      return false;
    }
  }
  return true;
}

function notify(message) {
  notification.notify({
    title: 'Websocket',
    text: message
  });
}
