var ws = new WebSocket('ws://localhost:4567');
ws.onopen = function(){
	console.log('websocket opened');
};
ws.onclose = function(){
	console.log('websocket closed');
};
ws.onmessage = function(message) {
	self.port.emit('message', message.data);
};

self.port.on('response', function(response){
	ws.send(response);
});
