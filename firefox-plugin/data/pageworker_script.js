self.port.on('init', function(init_params) {
  
  var wsaddress = init_params.wsaddress,
      email = init_params.email,
      password = init_params.password,
      timeout = init_params.timeout;

  self.port.emit('notificate', 'Connecting ' + wsaddress);
      
  var ws = new WebSocket(wsaddress);

  self.port.emit('badge', {value: 'w', color: '#EEEE00'});

  ws.onopen = function(){
    self.port.emit('notificate', 'Opened');
  };

  ws.onclose = function() {
    self.port.emit('notificate', "Remotelly closed\nReconnection in " + timeout + " sec");
    setTimeout("self.port.emit('Reconnect', '');", timeout * 1000)
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
