// heep_stack.ck
// A collection of works by Eric Heep.

ProgramNotes pn;

["floor", 
"impurities I/II",
"sort",
"thank you Peter Ablinger", 
"apollo 11 saturn V", 
"binary sines"] @=> string program[];

// here we go!
<<< "Program Notes", "" >>>;
<<< "-", "" >>>;

for (int i; i < program.cap(); i++) {
    <<< i + 1, "_", program[i], "" >>>;
    <<< pn.notes(program[i]), "" >>>;
    <<< "---", "" >>>;
}

// dedicated to Amy Mann, who trust me to move
// out to California so I could study, of all things,
// music technology
