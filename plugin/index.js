var sourceAddress = require('sdk/simple-prefs').prefs["Websocket server address"];

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
        let notification = require("sdk/notifications").notify({
            title: "Source address: " + sourceAddress
        });

        var panel = require("sdk/panel").Panel({
            contentScriptFile: "./script.js"
        });

        panel.port.emit('sourceAddress', sourceAddress);
        
        panel.port.on('request', function(message){
            var request = require("sdk/request").Request({
                url: message,
                onComplete: function (response) {
                    panel.port.emit('response', response.text)
                }
            });
            request.get();
        });

        panel.port.on('notificate', function(message){
            let notification = require("sdk/notifications").notify({
                title: message
            });
        });
    }
});
