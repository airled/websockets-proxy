window.addEventListener('click', function(event) {
  if (event.target.getAttribute('title') === 'close') {
    self.port.emit('close', '');
  };
}, false);
