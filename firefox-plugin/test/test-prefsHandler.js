var preferences = require("sdk/simple-prefs"),
    handler = require("../lib/prefsHandler.js");

exports["test fetch preferences"] = function(assert) {
  preferences.prefs["Websocket address"] = "ws://test.com:1234";
  preferences.prefs["E-mail"] = "test@test.com";
  preferences.prefs["Password"] = "password123";
  preferences.prefs["Proxy address"] = "http://test.com:9999";
  preferences.prefs["Reconnection timeout"] = "20";
  var prefs = handler.fetch();
  assert.ok(prefs.wsaddress === "ws://test.com:1234");
  assert.ok(prefs.email === "test@test.com");
  assert.ok(prefs.password === "password123");
  assert.ok(prefs.proxyaddress === "http://test.com:9999");
  assert.ok(prefs.timeout === "20");
}

exports["test save preferences"] = function(assert) {
  prefs = {
    wsaddress: "ws://testeme.me:4321",
    email: "em@il.li",
    password: "verifyme",
    proxyaddress: "http://thereisno.spoon:9876",
    timeout: "100",
    profile: "default1"
  };
  handler.save(prefs);
  assert.ok(preferences.prefs["Websocket address"] === "ws://testeme.me:4321");
  assert.ok(preferences.prefs["E-mail"] === "em@il.li");
  assert.ok(preferences.prefs["Password"] === "verifyme");
  assert.ok(preferences.prefs["Proxy address"] === "http://thereisno.spoon:9876");
  assert.ok(preferences.prefs["Reconnection timeout"] === "100");
  assert.ok(preferences.prefs["Profile"] === "default1");
}

require("sdk/test").run(exports);
