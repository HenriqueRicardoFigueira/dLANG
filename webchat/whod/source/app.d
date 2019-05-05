import vibe.d;
import std.stdio;
class WebChats
{
    private Room[string] m_rooms;
	string persona;

    void get(HTTPServerRequest req, HTTPServerResponse res)
    {
        res.render!("index.dt");
		writeln("get");
    }

    void getRoom(string id, string name)
    {	
		writeln("getRoom");
         
		auto messages = getOrCreateRoom(id).messages;
		
		render!("room.dt", id, name, messages);
    }

    void postRoom(string id, string name, string message)
	{
		writeln("postRoom");
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message);
		redirect("room?id="~id.urlEncode~"&name="~name.urlEncode);
	}
	
	
	void getWS(string room, string name, scope WebSocket socket)
	{
		writeln("getWS");
		auto r = getOrCreateRoom(room);

		// watch for new messages in the history and send them
		// to the client
		runTask({
			// keep track of the last message that got already sent to the client
			// we assume that we sent all message so far
			auto next_message = r.messages.length;

			// send new messages as they come in
			while (socket.connected) {
				while (next_message < r.messages.length)
					socket.send(r.messages[next_message++]);
				r.waitForMessage(next_message);
			}
		});

		// receive messages from the client and add it to the history
		while (socket.waitForData) {
			auto message = socket.receiveText();
			if (message.length) r.addMessage(name, message);
		}
	}
    private Room getOrCreateRoom(string id)
	{
		writeln("getorRoom");
		if (auto pr = id in m_rooms){
			
			return *pr;
		}
		else{
			m_rooms[id] = new Room;
			//m_rooms[id].palavrasChave.setPersona(this.persona);
			return m_rooms[id];  
		}
	}
}
class palavrasChaves{
	string[] persona ;
	string[] comandos = ["HELP","TALKTOME","QUIT","/help","/quit"];

	void setPersona(string palavra){
		//inicializa a classe setando a persona
		this.persona[0] = palavra;
	}



	bool checaComandos(string palavra){
		//função que checa se é uma palavra reservada
		int tam = comandos.length;
		int i = 0;
		for (i = 0; i < tam;i++){
			writeln("CHECANDO");
			if (this.comandos[i] == palavra){
				return 1;
			}
		}
		return 0;
	}
	

	void comandoQuit(){
		render!("index.dt");
	}

	string comandoHelp(){
		string a =  "HELP | /help | QUIT | /quit";
		return a;
	}
	
}
final class Room {
	string[] messages;
	LocalManualEvent messageEvent;
	palavrasChaves palavrasChave = new palavrasChaves;
	//palavrasChave.setComandos();
	this()
	{
		messageEvent = createManualEvent();
		

	}

	void addMessage(string name, string message)
	{
		bool reservada = palavrasChave.checaComandos(message);
		
		if (reservada == 1){
		
			if (message == "/quit"){
				palavrasChave.comandoQuit();
				messages ~=  name ~ "Saiu >>>| .|<<<";
			}
			else if(message == "QUIT"){
				palavrasChave.comandoQuit();
				messages ~=  name ~ "Saiu >>>| .|<<<";
			}
			else if(message == "HELP"){
				string aux = palavrasChave.comandoHelp();
				messages ~= name ~ aux ;
			}
			messages ~= name ~ ": " ~ "";	
		}else {
			messages ~= name ~ ": " ~ message;
		}
		messageEvent.emit();


	}

	void waitForMessage(size_t next_message)
	{
		while (messages.length <= next_message)
			
			messageEvent.wait();
	}
}

void helloWorld(HTTPServerRequest req, HTTPServerResponse res)
{
    res.render!("index.dt");
}

void main()
{
	
    auto router = new URLRouter;
    router.registerWebInterface(new WebChats);
    //router.get("*", serveStaticFiles("views/");

    auto settings = new HTTPServerSettings;
    // Needed for SessionVar usage.
    settings.sessionStore = new MemorySessionStore;
    settings.port = 8080;
    listenHTTP(settings, router);
    runApplication();
}
