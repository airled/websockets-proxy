var notification = require("sdk/notifications"),
    { ToggleButton } = require("sdk/ui/button/toggle"),
    panels = require("sdk/panel"),
    storage = require("sdk/simple-storage").storage,
    config = require("./lib/configHandler.js"),
    preferences = require("./lib/prefsHandler.js"),
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
  buttonPanel.port.emit("changeMenu", "proxyIsOn");
}
else {
  buttonPanel.port.emit("changeMenu", "proxyIsOff");
}

var prefsPanel = panels.Panel({
  width: 340,
  height: 275,
  contentURL: self.data.url("prefs_panel/prefs_panel.html"),
  contentScriptFile: "./prefs_panel/prefs_panel.js"
});

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

    let prefs = preferences.fetch();
    if (prefs.wsaddress === "" || prefs.email === "" || prefs.password === "") {
      notify("Some fields are empty");
      return;
    }

    wsState = "on";

    buttonPanel.port.emit("changeMenu", "wsIsOn");
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
      pageWorker.port.emit("init", preferences.fetch());
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
    buttonPanel.port.emit("changeMenu", "wsIsOff");
    pageWorker.destroy();
    notify("Locally closed");
    setBadge("", "");
  }
}

function switchProxyState() {
  let proxyaddress = preferences.fetch().proxyaddress;
  if (proxyaddress === "") {
    notify("Proxy address is empty");
    return;    
  }
  else {
    proxyIp = proxyaddress.replace("http://", "").split(":")[0];
    proxyPort = parseInt(proxyaddress.replace("http://", "").split(":")[1], 10);
  }
  if (proxyState != "on") {
    storage.proxyState = "on";
    proxyState = "on";
    buttonPanel.port.emit("changeMenu", "proxyIsOn");
    setBadge("p", "#0000EE");
    config.store();
    config.set(proxyIp, proxyPort);
  }
  else {
    storage.proxyState = "off";
    proxyState = "off";
    buttonPanel.port.emit("changeMenu", "proxyIsOff");
    setBadge("", "");
    if (typeof storage.old == "undefined" || isEmpty(storage.old)) {
      config.reset();
    }
    else {
      config.restore();
    }
  }
}

function setBadge(char, color) {
  button.badge = char;
  button.badgeColor = color;
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
    title: "Websocket",
    text: message
  });
}

prefsPanel.port.on("close", function(msg) {
  prefsPanel.hide();
});

prefsPanel.port.on("saveprefs", function(prefs) {
  preferences.save(prefs);
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
      prefsPanel.port.emit("setprefs", preferences.fetch());
      prefsPanel.show();
      break;
  }
});

exports.isEmpty = isEmpty;
