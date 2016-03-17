var handler = require("../lib/configHandler.js"),
    config = require("sdk/preferences/service"),
    storage = require("sdk/simple-storage").storage;

exports["test setting config"] = function(assert) {
  handler.set("test1.com", 11111);
  assert.ok(config.get("network.proxy.type") === 1);
  assert.ok(config.get("network.proxy.http") === "test1.com");
  assert.ok(config.get("network.proxy.http_port") === 11111);
  assert.ok(config.get("network.proxy.no_proxies_on") === "localhost, 127.0.0.1");
  assert.ok(config.get("network.proxy.share_proxy_settings") === false);
}

exports["test storing config"] = function(assert) {
  handler.store();
  assert.ok(storage.old.type === 1);
  assert.ok(storage.old.ip === "test1.com");
  assert.ok(storage.old.port === 11111);
  assert.ok(storage.old.no === "localhost, 127.0.0.1");
  assert.ok(storage.old.shared === false);
}

exports["test restoring config"] = function(assert) {
  config.set("network.proxy.type", 2);
  config.set("network.proxy.http", "test2.com");
  config.set("network.proxy.http_port", 22222);
  config.set("network.proxy.no_proxies_on", "testhost:2222");
  config.set("network.proxy.share_proxy_settings", true);
  handler.store();
  config.set("network.proxy.type", 3);
  config.set("network.proxy.http", "test3.com");
  config.set("network.proxy.http_port", 33333);
  config.set("network.proxy.no_proxies_on", "testhost:3333");
  config.set("network.proxy.share_proxy_settings", false);
  handler.restore();
  assert.ok(config.get("network.proxy.type") === 2);
  assert.ok(config.get("network.proxy.http") === "test2.com");
  assert.ok(config.get("network.proxy.http_port") === 22222);
  assert.ok(config.get("network.proxy.no_proxies_on") === "testhost:2222");
  assert.ok(config.get("network.proxy.share_proxy_settings") === true);
}

exports["test resetting config"] = function(assert) {
  config.set("network.proxy.type", 4);
  config.set("network.proxy.http", "test4.com");
  config.set("network.proxy.http_port", 44444);
  config.set("network.proxy.no_proxies_on", "testhost:4444");
  config.set("network.proxy.share_proxy_settings", true);
  handler.reset();
  assert.ok(config.get("network.proxy.type") === 5);
  assert.ok(config.get("network.proxy.http") === "");
  assert.ok(config.get("network.proxy.http_port") === 0);
  assert.ok(config.get("network.proxy.no_proxies_on") === "localhost, 127.0.0.1");
  assert.ok(config.get("network.proxy.share_proxy_settings") === false);
}

require("sdk/test").run(exports);
