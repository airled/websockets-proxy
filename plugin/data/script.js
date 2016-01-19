var ws = new WebSocket('ws://localhost:4567');
ws.onopen = function(){
	console.log('websocket opened');
    self.port.emit('notificate', 'Websocket opened');
};
ws.onclose = function() {
    console.log('websocket closed');
	self.port.emit('notificate', 'Websocket closed');
};
ws.onmessage = function(message) {
	self.port.emit('message', message.data);
};

self.port.on('response', function(response) {
	ws.send(response);
});
