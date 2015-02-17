// heep/stack

// A collection of electronic and electro-acoustic works 
// by Eric Heep

Descriptions d;

[
"apollo 11 saturn V", 
"binaries",
"layered tails",
"rostftko", 
"stasis patterns"
] @=> string program[];

<<< "Notes", "" >>>;
<<< "-", "" >>>;

for (int i; i < program.cap(); i++) {
    <<< i + 1, "-", program[i], "" >>>;
    <<< d.notes(program[i]), "" >>>;
    <<< "-", "" >>>;
}
