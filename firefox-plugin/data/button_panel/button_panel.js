window.addEventListener("click", function(event) {
  self.port.emit("pluginMenuClick", event.target.getAttribute("title").toString());
}, false);

var wsDiv = document.getElementById("ws");
var proxyDiv = document.getElementById("proxy");

self.port.on("changeMenu", function(msg) {
  switch (msg) {
    case "wsIsOn":
      wsDiv.innerHTML = "Закрыть websocket";
      break;
    case "wsIsOff":
      wsDiv.innerHTML = "Открыть websocket";
      break;
    case "proxyIsOn":
      proxyDiv.innerHTML = "Выключить прокси";
      break;
    case "proxyIsOff":
      proxyDiv.innerHTML = "Включить прокси";
      break;
  }
});
