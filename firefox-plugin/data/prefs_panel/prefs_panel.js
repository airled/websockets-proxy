self.port.emit('getprefs', 'prefs');
self.port.on('prefs', function(prefs){
  document.getElementById('address').setAttribute('value', prefs.address);
  document.getElementById('email').setAttribute('value', prefs.email);
  document.getElementById('password').setAttribute('value', prefs.password);
});

window.addEventListener('click', function(event) {
  if (event.target.getAttribute('title') === 'close') {
    self.port.emit('close', '');
  };
}, false);
