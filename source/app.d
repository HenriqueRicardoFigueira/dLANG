import vibe.d;
import std.stdio;
string newpersona;
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

	void getNewroom(HTTPServerResponse res)
	{
		res.render!("newroom.dt");
	}
	/*
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
	}*/

	void getRoom(string id, string name, string tema, string answer)
	{
		string[] members;
		auto messages = getOrCreateRoom(id).messages;
		bool x =  m_rooms[id].checkPlayer(name);
		int c = 0;
		
		if(answer != null)
			m_rooms[id].setAnswer = answer;
		
		if (tema == null)
			tema = m_rooms[id].tema;

		if (x == false)
		{
			managementRoom(id, name, tema);
			members = m_rooms[id].members;
			render!("room.dt", id, name, messages, members, tema, answer);
		}
		else
		{	
			members = m_rooms[id].members;
			render!("room.dt", id, name, messages, members, tema, answer);
		}
	}

	void managementRoom(string id, string name, string tema)
	{
		auto px = new Player(name, id);
		m_rooms[id].addMembers(px);
		m_rooms[id].tema = tema;
	}

	void postRoom(string id, string name, string message, string answer)
	{	
		string tema = m_rooms[id].tema;
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message, m_rooms[id].answer);
		redirect("room?id=" ~ id.urlEncode ~ "&name=" ~ name.urlEncode ~ "&tema=" ~ tema.urlEncode ~ "&answer=" ~ answer.urlEncode);
	}

	private Room getOrCreateRoom(string id)
	{
		
		if (auto pr = id in m_rooms)
		{
			return *pr;
		
		} else
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
		string a = "> Para sair > QUIT | /quit \n				
					> Para saber as regras >  RULES | /rules \n";
		return a;
	}
	string comandoRules()
	{
		string a = "> A regras são simples: \n				
					> Um fala de cada vez \n				
					> Sempre que um player pergunta, é vez do mestre responder \n				
					> O mestre só pode responder 'sim' ou 'nao' \n				
					> Ganha quem acertar primeiro o personagem que o mestre é \n				
					> O mestre que comanda a sala e avisa quem ganha com o comando (GANHADOR player)";				
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

	void setScore()
	{
		this.score += 10;
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
/*
	void recriarListaPlayer(int i){
		int cont  = 0;
		int cont2 = 0;
		Player[] newplayerlist;
		while (cont < m_player.length){
			if(cont != i){
				newplayerlist[cont] = m_player[cont2];
				cont++;
			}
			cont2++;
		}
		m_player = newplayerlist;
	}
*/
	string getAnswer()
	{
		return answer;
	}
	
	void addMessage(string name, string message, string answer)
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


		if ((reservada == 1))
		{	
		 // COMANDOS DOS PLAYERS
			if ((message == "/quit") || (message == "QUIT"))
			{
				palavrasChave.comandoQuit();
				//				m_rooms[id].members[]
				messages ~= name ~ "	Saiu >>>| .|<<<";
				//recriarListaPlayer(c);
				messageEvent.emit();
				return;
			}
			else if (message == "HELP")
			{
				string aux = palavrasChave.comandoHelp();
				messages ~= name ~ ": " ~ aux;
				messageEvent.emit();
				return;
			}
		}	
		
		
		if((message == answer) && (!ismaster))
		{
			messages ~= name ~ " >> GANHOU <<  (Mestre use o comando NEWGAME para começar com uma nova persona)" ;
			player.setScore();
			saveLog(messages);
			messageEvent.emit();
			return;
		}
		
		if((newpersona.length > 0) && (ismaster))
		{
			newpersona = null;
			setAnswer(message);
			messages ~= name ~ " - > MUDOU A PERSONA DA PARTIDA < - " ;
			messageEvent.emit();
			messages ~= name ~ " Player da vez, faça uma pergunta. " ;
			messageEvent.emit();
			return; 
		}
		
		if ((winner == false) && (player.token == true) &&(message.length > 1))
		{	
			player.setToken(false);
			int vari = 0;
			if ((contador ==( m_player.length)-1))
			{
				writeln("token zerado");
				contador = 0;
				m_player[0].setToken(true);				
				vari = 1;
			} else if (ismaster)
			{
				writeln("token pro player");
				contador ++;
				m_player[contador].setToken(true);
				vari = 2;

			} else if (!ismaster)
			{
				writeln("token pro mestre");
				m_player[0].setToken(true);

				vari = 3;
			}
			
			if (ismaster == true)
			{
					if ((message == "SIM" ) || (message =="sim"))
					{// COMANDOS DO MESTRE
						messages ~= name ~  ": " ~"Sim";
					}
					else if((message == "NAO") || (message =="nao"))
					{
						messages ~= name ~  ": " ~"Não";
					}else if(message == "NEWGAME")
					{
						messages ~= name ~ " insira a nova persona -> " ;
						messageEvent.emit();
						newpersona = "80028922";
						return;
					}
			}

			else 
			{	
				messages ~= name ~ ": " ~ message;
			}	
		
			if(answer == message)
			{
				messages ~= name ~ " >> GANHOU << " ;
			}

			if(vari != 0)
			{
				if (vari == 1)
				{
					serverlog1 = " Sua vez mestre!"; 
					messages ~= serverlog1;
					
				} 
				else if (vari == 2)
				{
					serverlog2 = " Sua vez player ->";
					messages ~= serverlog2 ~ m_player[contador].name;
				}
				else if (vari == 3)
				{
					serverlog3 = " Sua vez mestre!"; 
				}
				messageEvent.emit();
			}
	
		}
		if ((message == "HELP")||(message == "/help"))
		{
			string aux = palavrasChave.comandoHelp();
			messages ~= name ~ ": " ~ aux;
		}
		else if(message == "RULES")
		{
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
		string a = "HELP | /help | QUIT | /quit | NEWGAME se for mestre\n ";
		return a;
	}

	void saveLog(string[] message)
	{
		File file = File("logSala", "w+");
		file.writeln("Sala:" , id);
		file.writeln("Tema:" , tema);
		foreach(Player playerdavez ; m_player){				
			file.writeln("Player:", playerdavez.name);
			file.writeln("Score:", playerdavez.score);
			file.writeln("Mestre:", playerdavez.master);
			file.writeln("\n");
		}
		
		file.writeln("-----------------------------------------------------------------------------------------------");
		file.writeln("Log Messages");
		foreach(string x; message)
		{
			file.writeln(x);	
		}
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