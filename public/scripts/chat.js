function sendMessage()
{
	var msg = document.getElementById("inputLine")
	socket.send(msg.value);
	msg.value = "";
	return false;
}

function connect(room, name)
{
	socket = new WebSocket("ws://127.0.0.1:8080/ws?room="+encodeURIComponent(room)+"&name="+encodeURIComponent(name));

	socket.onmessage = function(message) {
		var history = document.getElementById("history");
		var previous = history.textContent.trim();
		if (previous.length) previous = previous + "\n";
		history.textContent = previous + message.data;
		history.scrollTop = history.scrollHeight;
	}

	socket.onclose = function() {
		console.log("socket closed - reconnecting...");
		connect();
	}
}
