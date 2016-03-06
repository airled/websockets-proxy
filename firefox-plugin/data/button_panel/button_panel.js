window.addEventListener('click', function(event) {
  self.port.emit('pluginMenuClick', event.target.getAttribute('title').toString());
}, false);

var wsDiv = document.getElementById('ws');

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
