import vibe.d;
import std.stdio;
class WebChats
{
    private Room[string] m_rooms;
	string persona;

    void get(HTTPServerResponse res)
    {
        res.render!("index.dt");
        
    }   
    
    void getNewplayer(HTTPServerResponse res)
    {
        res.render!("newplayer.dt");
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
		}}


    void getRoom(string id, string name, string tema)
    {   
        string[] members;
        auto messages = getOrCreateRoom(id).messages;
        members = m_rooms[id].members;
        bool x = m_rooms[id].checkPlayer(name);
        if(x == false){
            managementRoom(id, name, tema);
            render!("room.dt", id, name, messages, members,tema);
        } else {
            
            render!("room.dt", id, name, messages, members,tema);
        }
		writeln("get");
    }


    void managementRoom(string id, string name, string tema){
        
        auto px = new Player(name, id, 0, true);
        string pname = px.name;
        m_rooms[id].addMembers(pname);
        m_rooms[id].tema = tema;
        
    }
   
    void postRoom(string id, string name, string message)
	{
		writeln("postRoom");
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message);
        string tema = m_rooms[id].tema;
		redirect("room?id="~id.urlEncode~"&name="~name.urlEncode~"&tema="~tema.urlEncode);
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
	string[] comandos = ["HELP","TALKTOME","QUIT","/help","/quit","You are"];

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
	

final class Player{
	bool token;
    string name;
    string room;
    int score;
    bool master;

    this(string name, string room, int score, bool master){
		this.token = false;
        this.name = name;
        this.room = room;
        this.score = score;
        this.master = master;
    }
}


final class Room {
	string[] messages;
	LocalManualEvent messageEvent;
	string tema;
    string[] members;
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
//				m_rooms[id].members[]
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

    void addMembers(string name)
    {
        members ~= name;
    }

    bool checkPlayer(string name)
    {
        foreach(string x; members){
            if(x == name)
                return true;
        }
        return false;
    }
	
	void comandoQuit(){
		render!("index.dt");
	}

	string comandoHelp(){
		string a =  "HELP | /help | QUIT | /quit";
		return a;
	}
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
