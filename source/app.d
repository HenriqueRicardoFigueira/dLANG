import vibe.d;

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
    }

    void managementRoom(string id, string name, string tema){
        
        auto px = new Player(name, id, 0, true);
        string pname = px.name;
        m_rooms[id].addMembers(pname);
        m_rooms[id].tema = tema;
        
    };
   
    void postRoom(string id, string name, string message)
	{
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message);
        string tema = m_rooms[id].tema;
		redirect("room?id="~id.urlEncode~"&name="~name.urlEncode~"&tema="~tema.urlEncode);
	}

    private Room getOrCreateRoom(string id)
	{
		if (auto pr = id in m_rooms) return *pr;
		return m_rooms[id] = new Room;
	}
}

final class Player{
    string name;
    string room;
    int score;
    bool master;

    this(string name, string room, int score, bool master){
        this.name = name;
        this.room = room;
        this.score = score;
        this.master = master;
    }
}

final class Room {
	string[] messages;
    string tema;
    string[] members;
    

	void addMessage(string name, string message)
	{
		messages ~= name ~ ": " ~ message;
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
