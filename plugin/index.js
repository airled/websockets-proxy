var sourceAddress = require('sdk/simple-prefs').prefs["Websocket server address"];
var notification = require("sdk/notifications");

var { ToggleButton } = require("sdk/ui/button/toggle");
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

    notification.notify({
      title: "Got source address: " + sourceAddress
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

    pageWorker.port.on('closeItLocally', function(message){
      pageWorker.destroy();
      button.state('window', {checked: false});
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

  else {
    pageWorker.destroy();
    notification.notify({
      title: "Websocket locally closed"
    });
  }
}
