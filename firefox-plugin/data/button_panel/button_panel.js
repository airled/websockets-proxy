window.addEventListener('click', function(event) {
  self.port.emit('pluginMenuClick', event.target.getAttribute('title').toString());
}, false);

var wsDiv = document.getElementById('ws');

self.port.on('turned_on', function(msg) {
  wsDiv.innerHTML = 'Закрыть websocket';
});

self.port.on('turned_off', function(msg) {
  wsDiv.innerHTML = 'Открыть websocket';
});
