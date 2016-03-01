var address = require('sdk/simple-prefs').prefs["Address"],
    email = require('sdk/simple-prefs').prefs["E-mail"],
    password = require('sdk/simple-prefs').prefs["Password"],
    notification = require("sdk/notifications"),
    { ToggleButton } = require("sdk/ui/button/toggle");

var button = ToggleButton({
  id: "Websocket",
  label: "Open a websocket",
  icon: {
    "16": "./16.png",
    "32": "./32.png",
    "64": "./64.png"
  },
  onChange: handleButton
});

function handleButton(state) {
  if (state.checked) {

    pageWorker = require("sdk/page-worker").Page({
      contentScriptFile: "./script.js"
    });

    var init_params = {
      'address': address,
      'email': email,
      'password': password
    };

    pageWorker.port.emit('init', init_params);
    
    pageWorker.port.on('notificate', function(message) {
      notification.notify({
        title: 'Websocket',
        text: message
      });
    });

    pageWorker.port.on('Reconnect', function(message) {
      pageWorker.port.emit('init', init_params);
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
    pageWorker.destroy();
    notification.notify({
      title: 'Websocket',
      text: "Locally closed"
    });
  }
}
