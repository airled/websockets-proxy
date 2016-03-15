// The handler works with four browser config proxy parameters HTTP ONLY:
// network.proxy.type for a proxy type (no proxy, system proxy, manual or auto)
// network.proxy.http for a http-proxy url without a port (like 8.8.8.8 or test.com)
// network.proxy.http_port for a http-proxy port
// network.proxy.no_proxies_on for a list of addresses, that won't be handled by browser proxy
// The plugin stores the current proxy parameters before changing its values
// and restores it after the plugin proxy is turned off.

var config = require("sdk/preferences/service"),
    storage = require("sdk/simple-storage").storage;

function setConfig(type, ip, port, no) {
  config.set("network.proxy.type", type);
  config.set("network.proxy.http", ip);
  config.set("network.proxy.http_port", port);
  config.set("network.proxy.no_proxies_on", no);
}

function storeConfig() {
  storage.old = {
    type: config.get("network.proxy.type"),
    ip:   config.get("network.proxy.http"),
    port: config.get("network.proxy.http_port"),
    no:   config.get("network.proxy.no_proxies_on")
  }
}

function restoreConfig() {
  setConfig(storage.old.type, storage.old.ip, storage.old.port, storage.old.no);
  delete storage.old;
}

function resetConfig() {
  config.reset("network.proxy.type");
  config.reset("network.proxy.http");
  config.reset("network.proxy.http_port");
  config.reset("network.proxy.no_proxies_on");
}

exports.set = setConfig;
exports.store = storeConfig;
exports.restore = restoreConfig;
exports.reset = resetConfig;
