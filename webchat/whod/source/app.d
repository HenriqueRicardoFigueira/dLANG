import vibe.d;
import std.stdio;

class WebChats
{
	private Room[string] m_rooms;

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
			while (socket.connected)
			{
				while (next_message < r.messages.length)
					socket.send(r.messages[next_message++]);
				r.waitForMessage(next_message);
			}
		});

		// receive messages from the client and add it to the history
		while (socket.waitForData)
		{
			auto message = socket.receiveText();
			if (message.length)
				r.addMessage(name, message);
		}
	}

	void getRoom(string id, string name, string tema, string answer)
	{
		string[] members;
		auto messages = getOrCreateRoom(id).messages;
		bool x =  m_rooms[id].checkPlayer(name);
		int c = 0;
		
		if (tema == null)
			tema = m_rooms[id].tema;

		if (x == false)
		{
			managementRoom(id, name, tema, answer);
			members = m_rooms[id].members;
			render!("room.dt", id, name, messages, members, tema, answer);
		}
		else
		{
			members = m_rooms[id].members;
			render!("room.dt", id, name, messages, members, tema, answer);

		}
	}

	void managementRoom(string id, string name, string tema, string answer)
	{
		auto px = new Player(name, id);
		m_rooms[id].addMembers(px);
		m_rooms[id].tema = tema;
		m_rooms[id].setAnswer = answer;
		writeln(answer);
	}

	void postRoom(string id, string name, string message, string answer)
	{	
		string tema = m_rooms[id].tema;
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message);
		redirect("room?id=" ~ id.urlEncode ~ "&name=" ~ name.urlEncode ~ "&tema=" ~ tema.urlEncode ~ "&answer=" ~ answer.urlEncode);
	}

	private Room getOrCreateRoom(string id)
	{
		
		if (auto pr = id in m_rooms)
		{
			return *pr;
		
		}else
		
		{
			m_rooms[id] = new Room;
			m_rooms[id].setId(id);
			return m_rooms[id];
		}
	}

}

class palavrasChaves
{
	string persona;
	string[] comandos = ["HELP", "TALKTOME", "QUIT", "/help", "/quit", "You are"];

	void setPersona(string palavra)
	{
		//inicializa a classe setando a persona
		this.persona = palavra;
	}

	bool checaComandos(string palavra)
	{
		//função que checa se é uma palavra reservada
		auto tam = comandos.length;
		int i = 0;
		for (i = 0; i < tam; i++)
		{
			if (this.comandos[i] == palavra)
			{
				return 1;
			}
		}
		return 0;
	}

	void comandoQuit()
	{
		render!("index.dt");
	}

	string comandoHelp()
	{
		string a = "  > Para sair > QUIT | /quit \n				> Para saber as regras >  RULES | /rules \n";
		return a;
	}
	string comandoRules()
	{
		string a = "  > A regras são simples: \n				> Um fala de cada vez \n				> Sempre que um player pergunta, é vez do mestre responder \n				> O mestre só pode responder 'sim' ou 'nao' \n				> Ganha quem acertar primeiro o personagem que o mestre é \n				> O mestre que comanda a sala e avisa quem ganha com o comando (GANHADOR player)";				
		return a;
	}
}

final class Player
{
	string name;
	string room;
	int score;
	bool master;
	bool token;

	this(string name, string room)
	{
		this.name = name;
		this.room = room;
	}

	void setToken(bool tok)
	{
		this.token = tok;
	}

	void setMaster(bool xxx)
	{
		this.master = xxx;
	}

	void setScore(int result)
	{
		this.score = result;
	}
}

final class Room
{
	string id;
	string[] messages;
	LocalManualEvent messageEvent;
	string tema;
	string[] members;
	palavrasChaves palavrasChave = new palavrasChaves;
	Player[] m_player;
	string answer;

	int contador = 0;
	
	this()
	{	
		messageEvent = createManualEvent();
	}

	void setId(string id)
	{
		this.id = id;
	}

	void setAnswer(string answer)
	{
		this.answer = answer;
	}

	void addMessage(string name, string message)
	{
		bool reservada = palavrasChave.checaComandos(message);
		string serverlog1,serverlog2,serverlog3;
		int c = 0;
		bool ismaster = false;
		Player[] lista = m_player;
		bool winner = false;
		
		foreach(Player palavradavez ; lista){				
			if (palavradavez.name == name){	
				
				//m_player[palavradavez].setToken(false);				
					if (lista[c].master == true){						
						ismaster = true;
						break;
					}
					break;
				}
				c++;
			}
		Player player = m_player[c];
		if ((winner == false) && (player.token == true) &&(message.length > 0)){	
			player.setToken(false);
			if (contador ==( m_player.length)-1){
				writeln("token zerado");
				m_player[0].setToken(true);

				serverlog1 = " token zerado. Sua vez mestre!"; 
				contador = 0;
			}else if(ismaster){
				//m_player[0].setToken(true);
				writeln("token pro player");
				contador ++;
				serverlog2 =  " Sua vez!";
				m_player[contador].setToken(true);
			}else if(!ismaster){
				writeln("token pro mestre");
				m_player[0].setToken(true);
				serverlog3 = " Sua vez mestre!"; 
				
			}
			
			if (ismaster == true){
					if ((message == "SIM" ) || (message =="sim")){// COMANDOS DO MESTRE
						messages ~= name ~  ": " ~"Sim";
						
					}
					else if((message == "NAO") || (message =="nao")){
						messages ~= name ~  ": " ~"Não";
					}
		

			}
			else if ((reservada == 1)){	



				 // COMANDOS DOS PLAYERS
					if ((message == "/quit") || (message == "QUIT")){
						palavrasChave.comandoQuit();
							//				m_rooms[id].members[]
						messages ~= name ~ "Saiu >>>| .|<<<";
					}
					else if (message == "HELP"){
						string aux = palavrasChave.comandoHelp();
						messages ~= name ~ ": " ~ aux;
					}
				
			}else {
				
				messages ~= name ~ ": " ~ message;


			}	
	
		}
		if ((message == "HELP")||(message == "/help")){
			string aux = palavrasChave.comandoHelp();
			messages ~= name ~ ": " ~ aux;
			}
		else if(message == "RULES"){
			string aux = palavrasChave.comandoRules();
			messages ~= name ~ ": " ~ aux;
		}

		messageEvent.emit();
	}

	void waitForMessage(size_t next_message)
	{
		while (messages.length <= next_message)

			messageEvent.wait();
	}

	void addMembers(Player p1)
    {
        if(m_player.length == 0)
		{
            p1.setMaster(true);
			p1.setToken(true);
		}
		
		m_player ~= p1;
        members ~= p1.name;
        writeln(p1.master);
    }


	bool checkPlayer(string name)
	{
		foreach (string x; members)
		{
			if (x == name)
				return true;
		}
		return false;
	}

	void comandoQuit()
	{
		render!("index.dt");
	}

	string comandoHelp()
	{
		string a = "HELP | /help | QUIT | /quit";
		return a;
	}
}

void main()
{

	auto router = new URLRouter;
	router.registerWebInterface(new WebChats);
	//router.get("*", serveStaticFiles("views/");

	auto settings = new HTTPServerSettings;
	
	
	settings.port = 8080;
	listenHTTP(settings, router);
	runApplication();
}
