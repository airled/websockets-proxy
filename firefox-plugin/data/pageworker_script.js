self.port.on('init', function(init_params) {
  
  var wsaddress = init_params.wsaddress,
      email = init_params.email,
      password = init_params.password,
      timeout = init_params.timeout,
      profile = init_params.profile;

  if (wsaddress.slice(0,5) !== 'ws://') {
    wsaddress = 'ws://' + wsaddress;
  }

  // self.port.emit('notificate', 'Connecting ' + wsaddress);
      
  var ws = new WebSocket(wsaddress);

  self.port.emit('badge', {value: 'w', color: '#EEEE00'});

  ws.onopen = function(){
    // self.port.emit('notificate', 'Opened');
  };

  ws.onclose = function() {
    if (timeout === '' || timeout < 10) {
      timeout = 10;
    }
    self.port.emit('notificate', "Remotelly closed\nReconnection in " + timeout + " sec");
    setTimeout("self.port.emit('reconnect', '');", timeout * 1000);
    self.port.emit('badge', {value: 'w', color: '#EE0000'});
  };

  ws.onmessage = function(request) {
    if (request.data === 'login') {
      var init_message = {
        email: email,
        password: password,
        profile: profile
      };
      ws.send(JSON.stringify(init_message));
    }
    else if (request.data === 'auth_ok') {
      self.port.emit('notificate', 'Successfully authenticated');
      self.port.emit('badge', {value: 'w', color: '#008800'});
    }
    else if (request.data === 'auth_failed') {
      self.port.emit('notificate', 'Authentication failed');
      self.port.emit('shutdown', '');
    }
    else if (request.data === 'wrong_profile') {
      self.port.emit('notificate', 'No such profile');
      self.port.emit('shutdown', '');
    }
    else if (request.data === 'busy_profile') {
      self.port.emit('notificate', 'This profile is already active');
      self.port.emit('shutdown', '');
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
