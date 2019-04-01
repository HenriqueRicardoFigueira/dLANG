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

    public this(){
        /*
        Construtor da partida / tema / player
        */
    }

}
class tema : partida {
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

    public this(){
        super();
    }
}



class player : partida {
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




    public this(){
        super();
    }
}