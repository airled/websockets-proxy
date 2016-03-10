self.port.on('setprefs', function(prefs){
  document.getElementById('wsaddress').setAttribute('value', prefs.wsaddress);
  document.getElementById('email').setAttribute('value', prefs.email);
  document.getElementById('password').setAttribute('value', prefs.password);
  document.getElementById('proxyaddress').setAttribute('value', prefs.proxyaddress);
});

window.addEventListener('click', function(event) {
  switch (event.target.getAttribute('title')){
    case 'close':
      self.port.emit('close', '');
      break;
    case 'save':
      self.port.emit('saveprefs', {
        wsaddress: document.getElementById('wsaddress').value,
        email: document.getElementById('email').value,
        password: document.getElementById('password').value,
        proxyaddress: document.getElementById('proxyaddress').value,
      });
      self.port.emit('close', '');
      break;
  };
}, false);
