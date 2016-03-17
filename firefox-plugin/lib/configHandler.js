// The handler works with five browser config proxy parameters HTTP ONLY:
// network.proxy.type for a proxy type (no proxy, system proxy, manual or auto)
//   plugin will set to '1' - manual
// network.proxy.http for a http-proxy url without a port (like 8.8.8.8 or test.com)
//   plugin will set the value from the plugin 'address' field of preferences
// network.proxy.http_port for a http-proxy port
//   plugin will set the value from the plugin 'address' field of preferences
// network.proxy.no_proxies_on for a list of addresses, that won't be handled by browser proxy
//   plugin will set default value "localhost, 127.0.0.1"
// network.proxy.share_proxy_settings for sharing proxy parameters to the other protols like FTP, SOCKS
//   plugin will set 'false'
// The plugin stores the user parameters before changing its values
// and restores it after the plugin proxy is turned off.

var config = require("sdk/preferences/service"),
    storage = require("sdk/simple-storage").storage;

function setConfig(ip, port) {
  config.set("network.proxy.type", 1);
  config.set("network.proxy.http", ip);
  config.set("network.proxy.http_port", port);
  config.set("network.proxy.no_proxies_on", "localhost, 127.0.0.1");
  config.set("network.proxy.share_proxy_settings", false);
}

function storeConfig() {
  storage.old = {
    type:   config.get("network.proxy.type"),
    ip:     config.get("network.proxy.http"),
    port:   config.get("network.proxy.http_port"),
    no:     config.get("network.proxy.no_proxies_on"),
    shared: config.get("network.proxy.share_proxy_settings")
  }
}

function restoreConfig() {
  config.set("network.proxy.type", storage.old.type);
  config.set("network.proxy.http", storage.old.ip);
  config.set("network.proxy.http_port", storage.old.port);
  config.set("network.proxy.no_proxies_on", storage.old.no);
  config.set("network.proxy.share_proxy_settings", storage.old.shared);
  delete storage.old;
}

function resetConfig() {
  config.reset("network.proxy.type");
  config.reset("network.proxy.http");
  config.reset("network.proxy.http_port");
  config.reset("network.proxy.no_proxies_on");
  config.reset("network.proxy.share_proxy_settings");
}

exports.set = setConfig;
exports.store = storeConfig;
exports.restore = restoreConfig;
exports.reset = resetConfig;
