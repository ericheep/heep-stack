// heep_stack.ck
// A collection of works by Eric Heep.

ProgramNotes pn;

["stasis patterns", 
"bring out your dead",
"impurities II (tentative)",
"tail sort (tentative)", 
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

// for Amy, who trust me to move too far away,
// to study of all things, music technology
