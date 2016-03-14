window.addEventListener('click', function(event) {
  self.port.emit('pluginMenuClick', event.target.getAttribute('title').toString());
}, false);

var wsDiv = document.getElementById('ws');
var proxyDiv = document.getElementById('proxy');

self.port.on('wsStateIs', function(msg) {
  switch (msg) {
    case 'on':
      wsDiv.innerHTML = 'Закрыть websocket';
      break;
    case 'off':
      wsDiv.innerHTML = 'Открыть websocket';
      break;
  }
});

self.port.on('proxyStateIs', function(msg) {
  switch (msg) {
    case 'on':
      proxyDiv.innerHTML = 'Выключить прокси';
      break;
    case 'off':
      proxyDiv.innerHTML = 'Включить прокси';
      break;
  }
});
