self.port.on('init', function(init_params) {

  var address = init_params.address,
      email = init_params.email,
      password = init_params.password,
      ws = new WebSocket(address);

  self.port.emit('badge', {value: 'w', color: '#EEEE00'});

  ws.onopen = function(){
    self.port.emit('notificate', 'Opened');
  };

  ws.onclose = function() {
    self.port.emit('notificate', "Remotelly closed\nReconnection in 10 sec");
    setTimeout("self.port.emit('Reconnect', '');", 10000)
    self.port.emit('badge', {value: 'w', color: '#EE0000'});
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
      self.port.emit('badge', {value: 'w', color: '#008800'});
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
