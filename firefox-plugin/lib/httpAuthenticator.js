var main = require("../index.js"),
    helper = require("./helper.js"),
    storage = require("sdk/simple-storage").storage,
    observer = require("./httpObserver.js");

function authenticate(email, password, profile) {
  var request = require("sdk/request").Request({
    // url: "http://127.0.0.1:3102/get_queue",
    url: "http://51.254.10.211:8081/get_queue",
    content: {
      email: email,
      password: password,
      profile: profile
    },
    anonymous: true,
    onComplete: function(response) {
      if (response.json == null){
        helper.notify("Failed connect to server");
        main.switchProxyState();
      }
      else if (response.json.result === "ok") {
        helper.notify("Proxy is on");
        storage.queue = response.json.queue;
        observer.register();
        main.setBadge("p", "#0000EE");
        helper.notify(response.json.queue);
      }
      else if (response.json.result === "failed") {
        helper.notify("Some prefs are not correct");
        main.switchProxyState();
      }
    }
  });
  request.post();
}

exports.authenticate = authenticate;
