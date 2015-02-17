// Descriptions.ck

public class Descriptions {

    fun string notes(string n) {
        if (n == "apollo 11 saturn V") {
            return "live sampling of a narration done by 
            Mark Gray that describes the take off of the 
            Apollo 11 Saturn V rocket 
            
            'Science is not only compatible with spirituality;
            it is a profound source of spirituality', C. Sagan
            " ; 
        }
        if (n == "binaries") {
            return "the octave is split multiple times according
            to equal divisions of the harmonic series, the notes
            inside each octave decided by a binary counter.
            one octave refers to a two bit system, a twelfth 
            refers to a three bit system, two octaves refer to a
            four bit system, etc";
        }
        if (n == "layered tails") {
            return "two microphones are placed on opposite sides 
            of the room, facing the audience. the piece live 
            samples the ambient noise of the room, while performing 
            a heap-sort on various rhythmic patterns which
            decides the output";
        }
        if (n == "rostftko") {
            return "an inverse fft is performed on various 
            Rothko paintings, two at a time, one hard panned
            left, the other hard panned right

            'Silence is so accurate', M. Rothko";
        }
        if (n == "stasis patterns") {
            return "a network piece for the CalArts
            live coding/laptop ensemble (Calork), requires
            at least 3 computers with the most recent ChucK
            installed, as well as a router with enough cables
            for each player (some can be wireless if needed, 
            although you'll probably drop OSC messages),
            the program must be run from terminal";
        }
    }
}
