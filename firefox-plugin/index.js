var helper = require("./lib/helper.js"),
    { ToggleButton } = require("sdk/ui/button/toggle"),
    panels = require("sdk/panel"),
    storage = require("sdk/simple-storage").storage,
    config = require("./lib/configHandler.js"),
    preferences = require("./lib/prefsHandler.js"),
    observer = require("./lib/httpObserver.js"),
    authenticator = require("./lib/httpAuthenticator.js");

var wsState = "off";
var proxyState = storage.proxyState;
var queueHeaderState = "off";

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
  contentURL: "./button_panel/button_panel.html",
  contentScriptFile: "./button_panel/button_panel.js",
  onHide: handleButtonPanelHide
});

if (proxyState === "on") {
  setBadge("p", "#EEEE00");
  buttonPanel.port.emit("changeMenu", "proxyIsOn");
  authenticator.authenticate(preferences.fetch().email, preferences.fetch().password, preferences.fetch().profile);
}
else {
  buttonPanel.port.emit("changeMenu", "proxyIsOff");
}

var prefsPanel = panels.Panel({
  width: 280,
  height: 340,
  contentURL: "./prefs_panel/prefs_panel.html",
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
    if (prefs.wsaddress === "" || prefs.email === "" || prefs.password === "" || prefs.profile === "") {
      helper.notify("Some preferences for websocket are empty");
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

    pageWorker.port.on("shutdown", function(message) {
      wsSwitch();
    });

    pageWorker.port.on("notificate", function(message) {
      helper.notify(message);
    });

    pageWorker.port.on("reconnect", function(message) {
      pageWorker.port.emit("init", preferences.fetch());
    });
    
    pageWorker.port.on("request", function(request) {
      var data = JSON.parse(request);
      var request = require("sdk/request").Request({
        url: data.url,
        headers: data.headers,
        content: data.params,
        anonymous: true,
        onComplete: function(response) {
          responseHeaders = response.headers;
          delete responseHeaders["Transfer-Encoding"];
          delete responseHeaders["Content-Encoding"];
          let responseData = {
            reply_to: data.reply_to,
            status: response.status,
            headers: responseHeaders,
            body: response.text
          };
          pageWorker.port.emit("response", JSON.stringify(responseData));
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
    setBadge("", "");
  }
}

function switchProxyState() {

  let prefs = preferences.fetch();
  if (prefs.email === '' || prefs.password === '' || prefs.proxyaddress === "" || prefs.profile === "") {
    helper.notify("Some prefs fields are empty");
    return;    
  }
  else {
    proxyIp = prefs.proxyaddress.replace("http://", "").split(":")[0];
    proxyPort = parseInt(prefs.proxyaddress.replace("http://", "").split(":")[1], 10);
  }
  if (proxyState !== "on") {
    authenticator.authenticate(prefs.email, prefs.password, prefs.profile);
    setBadge("p", "#EEEE00");
    storage.proxyState = "on";
    proxyState = "on";
    buttonPanel.port.emit("changeMenu", "proxyIsOn");
    config.store();
    config.set(proxyIp, proxyPort);
  }
  else {
    storage.proxyState = "off";
    proxyState = "off";
    if (queueHeaderState === "on") {
      observer.unregister();
    }
    buttonPanel.port.emit("changeMenu", "proxyIsOff");
    setBadge("", "");
    if (typeof storage.old == "undefined" || helper.checkEmpty(storage.old)) {
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

function setQueueHeaderState(value) {
  queueHeaderState = value;
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

exports.setBadge = setBadge;
exports.setQueueHeaderState = setQueueHeaderState;
exports.switchProxyState = switchProxyState;
