var main = require("../index.js"),
    helper = require("./helper.js"),
    storage = require("sdk/simple-storage").storage,
    observer = require("./httpObserver.js");

function authenticate(email, password) {
  var request = require("sdk/request").Request({
    url: "http://51.254.10.211:8081/auth",
    content: {
      'email': email,
      'password': password
    },
    anonymous: true,
    onComplete: function(response) {
      if (response.json == null){
        helper.notify('failed connect to server');
        main.setBadge('p', '#EE0000');
      }
      else if (response.json.result === "ok") {
        helper.notify('http authentication ok');
        storage.queue = response.json.queue;
        observer.register();
        main.setBadge('p', '#0000EE');
      }
      else if (response.json.result === "failed") {
        helper.notify('http authentication failed');
        main.setBadge('p', '#EE0000');
      }
    }
  });
  request.post();
}

exports.authenticate = authenticate;
