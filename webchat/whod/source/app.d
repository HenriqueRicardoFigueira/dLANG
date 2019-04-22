import vibe.vibe;



final class WebChat {
	private Room[string] m_rooms;
	void get()
	{
		render!"index.dt";
	}


	void getRoom(string id, string name)
	{
		auto messages = getOrCreateRoom(id).messages;
		render!("room.dt", id, name, messages);
	}

	void postRoom(string id, string name, string message)
	{
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message);
		redirect("room?id="~id.urlEncode~"&name="~name.urlEncode);
	}



	void getWS(string room, string name, scope WebSocket socket)
	{
		auto r = getOrCreateRoom(room);

		runTask({

			auto next_message = r.messages.length;

			while (socket.connected) {
				while (next_message < r.messages.length)
					socket.send(r.messages[next_message++]);
				r.waitForMessage(next_message);
		}});
		while (socket.waitForData) {
			auto message = socket.receiveText();
			if (message.length) r.addMessage(name, message);
		}


		
	}
	private Room getOrCreateRoom(string id)
	{
		if (auto pr = id in m_rooms) return *pr;
		return m_rooms[id] = new Room;
	}
}

final class Room {
	string[] messages;
	LocalManualEvent messageEvent;

	this()
	{
		messageEvent = createManualEvent();
	}

	void addMessage(string name, string message)
	{
		messages ~= name ~ ": " ~ message;
		messageEvent.emit();
	}

	void waitForMessage(size_t next_message)
	{
		while (messages.length <= next_message)
			messageEvent.wait();
	}
}





void main()
{
	auto router = new URLRouter; // instancia do criador de rotas
	router.registerWebInterface(new WebChat);// transforma o objeto webchat em rota
	router.get("*", serveStaticFiles("public/"));// chama o arquivo java script 




	auto settings = new HTTPServerSettings; //instancia do servidor http
	settings.port = 8080;// defina porta 8080
	settings.bindAddresses = ["::1", "127.0.0.1"]; //endereço de rede



	listenHTTP(settings, router);
	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
}
