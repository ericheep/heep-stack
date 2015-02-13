
// California Institue of the Arts
// The Herb Alpert School of Music at CalArts
// Presents

// heep/stack

// A collection of works by MFA student Eric Heep
// Music Technology, MTIID


ProgramNotes pn;

["stasis patterns", 
"layered tails",
"rostftko", 
"apollo 11 saturn V", 
"binaries"] @=> string program[];

// ~ here we go
<<< "Program Notes", "" >>>;
<<< "-", "" >>>;

for (int i; i < program.cap(); i++) {
    <<< i + 1, "-", program[i], "" >>>;
    <<< pn.notes(program[i]), "" >>>;
    <<< "-", "" >>>;
}


// Saturday, February 14th, 2015
// 2:00 PM
// Roy O. Disney Music Hall

// Thanks to Manuel, Shauryja, Edward, Justin, Danny,
// Ajay, Jordan, Owen, and anyone else I might have forgotten 

// for Amy


class ProgramNotes {

    fun string notes(string n) {
        if (n == "stasis patterns") {
            return "a network piece for the CalArts
            live coding/laptop ensemble (Calork)";
        }
        if (n == "layered tails") {
            return "a meditation";
        }
        if (n == "rostftko") {
            return "'Silence is so accurate', M. Rothko";
        }
        if (n == "apollo 11 saturn V") {
            return "'Science is not only compatible with spirituality;
            it is a profound source of spirituality', C. Sagan" ; 
        }
        if (n == "binaries") {
            return "growing systems, splitting the octave";
        }
    }
}
