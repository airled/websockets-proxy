self.port.on('sourceAddress', function(address) {
  var sourceAddress = address,
    ws = new WebSocket(address);

  ws.onopen = function(){
    self.port.emit('notificate', 'Websocket opened');
  };

  ws.onclose = function() {
    self.port.emit('notificate', 'Websocket remotelly closed');
    self.port.emit('closeItLocally','')
  };

  ws.onmessage = function(request) {
    if (request.data == 'login') {
      self.port.emit('notificate', 'Got login-message. Sending auth data...');
      var init_message = {
        'login': 'testlogin',
        'password': 'testpassword'
      };
      ws.send(JSON.stringify(init_message));
    }
    else if (request.data == 'auth_ok') {
      self.port.emit('notificate', 'Successfully authenticated');
    }
    else {
      // self.port.emit('notificate', request.data);
      self.port.emit('request', request.data);
    }
  };
  
  self.port.on('response', function(response) {
    ws.send(response);
  });
});
