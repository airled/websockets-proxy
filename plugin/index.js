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
      var data = JSON.parse(message); //basic request json with all the data
      var url = data.url;   //request location like "http://example.com:1234/mydata"
      var method = data.method;       //request method
      var query = data.query;         //request query for non-get methods
      var cookies = data.cookies;     //request cookies
      switch (method) {
        case 'GET':
          var request = require("sdk/request").Request({
            url: url,
            headers: {
              // User-Agent: agent,
              Cookie: cookies
            },
            onComplete: function(response){
              var responseCookies = response.headers['Set-Cookie']
              var responseText = response.text
              var responseData = {
                cookies: responseCookies,
                text: responseText
              };
              var responseJson = JSON.stringify(responseData);
              pageWorker.port.emit('response', responseJson);
            }
          });
          request.get();
          break;
        case 'POST':
          var request = require("sdk/request").Request({
            url: url,
            headers: {
              // User-Agent: agent,
              Cookie: cookies
            },
            content: query,
            onComplete: function(response){
              var responseCookies = response.headers['Set-Cookie']
              var responseText = response.text
              var responseData = {
                cookies: responseCookies,
                text: responseText
              };
              var responseJson = JSON.stringify(responseData);
              pageWorker.port.emit('response', responseJson);
            }
          });
          request.post();
          break;
      }
    });
    
  }
  else {
    pageWorker.destroy();
    notification.notify({
      title: "Websocket locally closed"
    });
  }
}
