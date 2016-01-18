var panel = require("sdk/panel").Panel({
  contentScriptFile: "./script.js"
});

panel.port.on('message', function(message){
  var request = require("sdk/request").Request({
    url: message,
    overrideMimeType: "text/plain; charset=latin1",
    onComplete: function (response) {
      panel.port.emit('response', response.text)
    }
  });
  request.get();
});
