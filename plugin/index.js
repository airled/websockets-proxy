var sourceAddress = require('sdk/simple-prefs').prefs["Websocket server address"],
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
    notification.notify({ title: "Got source address: " + sourceAddress });

    pageWorker = require("sdk/page-worker").Page({
      contentScriptFile: "./script.js"
    });

    pageWorker.port.emit('sourceAddress', sourceAddress);
    
    pageWorker.port.on('notificate', function(message) {
      notification.notify({ title: message });
    });

    pageWorker.port.on('closeItLocally', function(message) {
      pageWorker.destroy();
      button.state('window', {checked: false});
    });
    
    /////////////////REQUEST HANDLER/////////////////
    
    pageWorker.port.on('request', function(request) {
      var data = JSON.parse(request);
      // data = {url, method, query, cookies, agent, referer, reply_to} of request
      var request = require("sdk/request").Request({
        url: data.url,
        headers: {
          'User-Agent': data.agent,
          'Referer': data.referer,
          'Cookie': data.cookies
        },
        content: data.query,
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
    notification.notify({ title: "Websocket locally closed" });
  }
}
