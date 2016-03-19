var main = require("../index.js"),
    storage = require("sdk/simple-storage").storage,
    {Cc, Ci} = require("chrome");

var httpRequestObserver =
{
  observe: function(subject, topic, data) {
    if (topic == "http-on-modify-request") {
      var httpChannel = subject.QueryInterface(Ci.nsIHttpChannel);
      httpChannel.setRequestHeader("PERSONALQUEUE", storage.queue, false);
    }
  },

  get observerService() {
    return Cc["@mozilla.org/observer-service;1"].getService(Ci.nsIObserverService);
  },

  register: function() {
    this.observerService.addObserver(this, "http-on-modify-request", false);
    main.setQueueHeaderState("on");
  },

  unregister: function() {
    this.observerService.removeObserver(this, "http-on-modify-request");
    main.setQueueHeaderState("off");
  }
};

function register() {
  httpRequestObserver.register();
}

function unregister() {
  httpRequestObserver.unregister();
}

exports.register = register;
exports.unregister = unregister;
