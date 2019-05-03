import vibe.d;

class WebChats
{
    private Room[string] m_rooms;

    void get(HTTPServerResponse res)
    {
        res.render!("index.dt");
    }

    void getRoom(string id, string name, string tema)
    {
        string[] members;
        auto messages = getOrCreateRoom(id).messages;
		m_rooms[id].addMembers(name);
        members = m_rooms[id].members;
        //Player[name, id, 0, true] = px;
        render!("room.dt", id, name, messages, members,tema);
    }

    void postRoom(string id, string name, string message)
	{
		if (message.length)
			getOrCreateRoom(id).addMessage(name, message);
		redirect("room?id="~id.urlEncode~"&name="~name.urlEncode);
	}

    private Room getOrCreateRoom(string id)
	{
		if (auto pr = id in m_rooms) return *pr;
		return m_rooms[id] = new Room;
	}
}

final class Player{
    string name;
    int room;
    int score;
    bool master;

    this(string name, int room, int score, bool master){
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
    /*
    void removeMembers(string name)
    {
        members = members.remove!(x => x == name);
    }*/
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
