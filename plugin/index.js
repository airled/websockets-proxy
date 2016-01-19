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
        var panel = require("sdk/panel").Panel({
            contentScriptFile: "./script.js"
        });
        
        panel.port.on('message', function(message){
            var request = require("sdk/request").Request({
                url: message,
                onComplete: function (response) {
                    panel.port.emit('response', response.text)
                }
            });
            request.get();
        });

        panel.port.on('notificate', function(message){
            var notification = require("sdk/notifications").notify({
                title: message
            });
        });
    }
});

// var panel = require("sdk/panel").Panel({
//     contentScriptFile: "./script.js"
// });

// panel.port.on('message', function(message){
//     var request = require("sdk/request").Request({
//         url: message,
//         onComplete: function (response) {
//             panel.port.emit('response', response.text)
//         }
//     });
//     request.get();
// });

// panel.port.on('notificate', function(message){
//     var notification = require("sdk/notifications").notify({
//         title: message
//     });
// });
