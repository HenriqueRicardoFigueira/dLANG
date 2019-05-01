import vibe.d;

class WebChats
{
    private Room[string] m_rooms;

    void get(HTTPServerRequest req, HTTPServerResponse res)
    {
        res.render!("index.dt");
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
    private Room getOrCreateRoom(string id)
	{
		if (auto pr = id in m_rooms) return *pr;
		return m_rooms[id] = new Room;
	}
}

final class Room {
	string[] messages;

	void addMessage(string name, string message)
	{
		messages ~= name ~ ": " ~ message;
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
