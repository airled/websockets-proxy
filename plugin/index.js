var sourceAddress = require('sdk/simple-prefs').prefs["Websocket server address"];
var notification = require("sdk/notifications");

var { ActionButton } = require("sdk/ui/button/action");
var button = ActionButton({
  id: "Websocket",
  label: "Open websocket",
  icon: {
    "16": "./16.png",
    "32": "./32.png",
    "64": "./64.png"
  },
  onClick: function(state) {
    notification.notify({
      title: "Source address: " + sourceAddress
    });

    pageWorker = require("sdk/page-worker").Page({
      contentScriptFile: "./script.js"
    });

    pageWorker.port.emit('sourceAddress', sourceAddress);
    
    pageWorker.port.on('notificate', function(message){
      notification.notify({
        title: message
      });
    });
    
    pageWorker.port.on('request', function(message){
      var request = require("sdk/request").Request({
        url: message,
        onComplete: function (response) {
          pageWorker.port.emit('response', response.text)
        }
      });
      request.get();
    });
  }
});
