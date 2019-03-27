import std.stdio;
import std.cstream;



class partida{
    public int numplayers = add_numplayers();
    public enum idplayers = set_idplayers();

/*
Setters
*/
    public enum set_idplayers(){
        return idplayers;
    }
    public int add_numplayers(){
        return numplayers + 1;
    }


}
class tema{
    private string nomedotema = set_nomedotema();
    private enum personas = set_iniciapersonas();
/*
Setters
*/
    private string set_nomedotema(){
        return nomedotema;
    }
    private enum set_iniciapersonas(){
        return personas;
    } 

/*
Getters
*/

    public void get_nomedotema(){
        return 0;
    }

    public void get_personas(){
        return 0;
    }

}



class player{
    private int id = set_idplayer();
    private string nomedoplayer = set_nomedoplayer();
    public persona = set_persona();

/*
Seters
*/
    private int set_idplayer(){
        return 0;
    }

    private string set_nomedoplayer(){
        return 0;
    }

/*
Getters
*/
}