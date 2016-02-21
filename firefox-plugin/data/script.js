self.port.on('init', function(init_params) {

  var sourceAddress = init_params.address,
      email = init_params.email,
      password = init_params.password,
      ws = new WebSocket(sourceAddress);

  ws.onopen = function(){
    self.port.emit('notificate', 'Opened');
  };

  ws.onclose = function() {
    self.port.emit('notificate', 'Remotelly closed');
    self.port.emit('closeItLocally', '');
  };

  ws.onmessage = function(request) {
    if (request.data == 'login') {
      var init_message = {
        'email': email,
        'password': password
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
