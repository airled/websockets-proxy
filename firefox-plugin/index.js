var notification = require("sdk/notifications"),
    { ToggleButton } = require("sdk/ui/button/toggle"),
    panels = require("sdk/panel"),
    preferences = require('sdk/simple-prefs'),
    self = require("sdk/self");

var wsState = 'off';

var button = ToggleButton({
  id: "bproxy",
  label: "BProxy",
  icon: {
    "16": "./16.png",
    "32": "./32.png",
    "64": "./64.png"
  },
  badge: '',
  onChange: handleButtonChange
});

var buttonPanel = panels.Panel({
  width: 170,
  height: 70,
  contentURL: self.data.url("button_panel/button_panel.html"),
  contentScriptFile: "./button_panel/button_panel.js",
  onHide: handleButtonPanelHide
});

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
    proxyaddress: preferences.prefs["Proxy-address"],
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
  button.state('window', {checked: false});
}

function wsSwitch() {
  if (wsState === 'off') {

    let prefs = fetchPrefs();
    if (prefs.wsaddress === '' || prefs.email === '' || prefs.password === '') {
      notification.notify({
        title: 'Websocket',
        text: 'Some fields are empty'
      });
      return;
    }

    wsState = 'on';

    buttonPanel.port.emit('wsStateIs', 'on');
    pageWorker = require("sdk/page-worker").Page({
      contentScriptFile: "./pageworker_script.js"
    });

    pageWorker.port.emit('init', prefs);
    
    pageWorker.port.on('badge', function(pair) {
      button.badge = pair.value;
      button.badgeColor = pair.color;
    });

    pageWorker.port.on('notificate', function(message) {
      notification.notify({
        title: 'Websocket',
        text: message
      });
    });

    pageWorker.port.on('Reconnect', function(message) {
      pageWorker.port.emit('init', fetchPrefs());
    });
    
    pageWorker.port.on('request', function(request) {
      var data = JSON.parse(request);
      var request = require("sdk/request").Request({
        url: data.url,
        headers: {
          'User-Agent': data.agent,
          'Referer': data.referer,
          'Cookie': data.cookies
        },
        content: data.query,
        anonymous: true,
        onComplete: function(response) {
          var responseData = {
            cookies: response.headers['Set-Cookie'],
            type: response.headers['Content-Type'],
            text: response.text,
            reply_to: data.reply_to
          };
          var responseJson = JSON.stringify(responseData);
          pageWorker.port.emit('response', responseJson);
        }
      });
      switch (data.method) {
        case 'GET':
          request.get();
          break;
        case 'POST':
          request.post();
          break;
        case 'PUT':
          request.put();
          break;
        case 'DELETE':
          request.delete();
          break;
        case 'HEAD':
          request.head();
          break;
      }
    });
  }
  else {
    wsState = 'off';
    buttonPanel.port.emit('wsStateIs', 'off');
    pageWorker.destroy();
    notification.notify({
      title: 'Websocket',
      text: "Locally closed"
    });
    button.badge = '';
  }
}

prefsPanel.port.on('close', function(msg) {
  prefsPanel.hide();
});

prefsPanel.port.on('saveprefs', function(prefs) {
  preferences.prefs["Websocket-address"] = prefs.wsaddress;
  preferences.prefs["E-mail"] = prefs.email;
  preferences.prefs["Password"] = prefs.password;
  preferences.prefs["Proxy-address"] = prefs.proxyaddress;
  preferences.prefs["Reconnection timeout"] = prefs.timeout;
});

buttonPanel.port.on('pluginMenuClick', function(title) {
  switch (title) {
    case 'ws':
      wsSwitch();
      break;
    case 'proxy':
      console.log('works');
      break;
    case 'prefs':
      prefsPanel.port.emit('setprefs', fetchPrefs());
      prefsPanel.show();
      break;
  }
});
