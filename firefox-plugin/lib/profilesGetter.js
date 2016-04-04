var main = require("../index.js"),
    helper = require("./helper.js");

function get_profiles(email, password) {
  var request = require("sdk/request").Request({
    url: "http://127.0.0.1:3102/get_profiles",
    // url: "http://51.254.10.211:8081/get_profiles",
    content: {
      email: email,
      password: password,
    },
    anonymous: true,
    onComplete: function(response) {
      if (response.json == null){
        helper.notify("Failed connect to server");
      }
      else if (response.json.result === "failed") {
        helper.notify("Some prefs are not correct");
      }
      else if (response.json.result === "ok") {
        helper.notify("Profiles got");
        main.setProxyProfilesInPrefsPanel(response.json.profiles);
      }
    }
  });
  request.post();
}

exports.get = get_profiles;
