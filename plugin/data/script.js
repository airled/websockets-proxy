self.port.on('sourceAddress', function(address) {
  var sourceAddress = address;

  var ws = new WebSocket(address);
  ws.onopen = function(){
    self.port.emit('notificate', 'Websocket opened');
  };
  ws.onclose = function() {
    self.port.emit('notificate', 'Websocket closed');
  };
  ws.onmessage = function(request) {
    self.port.emit('request', request.data);
  };

  self.port.on('response', function(response) {
    ws.send(response);
  });
});
