// stasis_patterns.ck

// keyboard controls
KBHit kb;

// custom class
CalorkOsc c;

// set your sending address
c.myAddr("/eric");

// add one IP and address at a time, two string arguments
c.addIp("192.168.1.6", "/nick");
//c.addIp("192.168.1.10", "/rodrigo");
//c.addIp("169.254.223.167", "/danny");
//c.addIp("169.254.207.86", "/mike");
//c.addIp("169.254.74.231", "/shaurjya");
//c.addIp("169.254.24.203", "/ed");

// you'll have to setup your parameters as an array of strings
c.setParams(["/gate", "/freq", "/click", "/oscil", "/mult"]);

// grabs player list 
c.addrs @=> string players[];

// grabs number of players
players.cap() => int NUM_PLAYERS;

// enables listening
spork ~ c.recv();

// sets number of sin oscs to number of players
SinOsc sin[NUM_PLAYERS];
ADSR env[NUM_PLAYERS];
Gain gate[NUM_PLAYERS];

// press spacebar to start
int begin;

// starting values
300 => float spd;
220 => float my_freq;
10 => float my_click;
0.0 => float my_oscil;
1.0 => float my_mult;

// frequency max and min
220 => float freq_max;
200 => float freq_min;

// storage for all sine stuffs
float mult[NUM_PLAYERS];
float click[NUM_PLAYERS];
float oscil[NUM_PLAYERS];

// sound chain set up
for (int i; i < NUM_PLAYERS; i++) {
    sin[i] => env[i] => dac;
    sin[i].gain(0.7);
}

// cycles backwards or forwards through the players
fun void cycle() {
    while (true) {  
        for (int i; i < NUM_PLAYERS; i++) {
            c.send(players[i], "/gate", 0);
            c.send(players[(i + 1) % NUM_PLAYERS], "/gate", 1); 
            spd::ms => now;
        }
    }
}

// triggered every incoming osc and everytime 
// a player sends to themselves
fun void update() {
    while (true) {
        c.e => now;
        for (int i; i < NUM_PLAYERS; i++) {
            c.getParam(players[i], "/click") => click[i];
            if (c.getParam(players[i], "/gate") == 1) {
                env[i].set(click[i]::ms, 0::ms, 1.0, 10::ms);
                env[i].keyOn(); 
            }
            if (c.getParam(players[i], "/gate") == 0) {
                env[i].set(click[i]::ms, 0::ms, 1.0, 10::ms);
                env[i].keyOff();
            }
            c.getParam(players[i], "/mult") => mult[i];
            c.getParam(players[i], "/oscil") => oscil[i];
            c.getParam(players[i], "/freq") * mult[i] * oscil[i] => sin[i].freq;
        }
    }
}

// keyboard input
fun void input() {
    while (true) {
        kb => now;
        while (kb.more()) {
            action(kb.getchar());
        }
    }
}

// prints out instructions
fun void instructions() {
    if (begin != 1) {
        // initializes click and mult
        send("/mult", my_mult);
        send("/click", my_click);
        send("/freq", my_freq);
        send("/oscil", my_oscil);
        spork ~ update();
        spork ~ cycle();
    }
    <<< " ", "" >>>;
    <<< "                         S T A S I S  P A T T E R N S ", "" >>>; 
    <<< " ", "" >>>;
    <<< "    [q] + speed    [w] + frequency    [e] + 3rd    [r] oscil on   [t] click on", "" >>>; 
    <<< " ", "" >>>; 
    <<< "    [a] - speed    [s] - frequency    [d] - 3rd    [f] oscil off  [g] click off", "" >>>; 
    <<< " ", "" >>>; 
}

// keyboard actions
fun void action(int key) {
    // q, speeds up rotation
    if (key == 113) {
        if (spd > 10) {
            5 -=> spd;
        }
    }
    // a, slows down rotation
    if (key == 97) {
        if (spd < 1000) {
            5 +=> spd;
        }
    }
    // w, raises frequency 
    if (key == 119) {
        if (my_freq < freq_max) {
            1 +=> my_freq; 
        }
        send("/freq", my_freq);
    }
    // s, lowers frequency 
    if (key == 115) {
        if (my_freq >= freq_min) {
            1 -=> my_freq; 
        }
        send("/freq", my_freq);
    }
    // e, turns on frequency multiplier 
    if (key == 101) {
        5.0/4.0 *=> my_mult; 
        send("/mult", my_mult);
    }
    // d, turns off frequency multiplier
    if (key == 100) {
        if (my_mult > 1.0) {
            5.0/4.0 /=> my_mult; 
        }
        send("/mult", my_mult);
    }
    // r, turns on oscillator 
    if (key == 114) {
        1 => my_oscil; 
        send("/oscil", my_oscil);
    }
    // f, turns off oscillator
    if (key == 102) {
        0 => my_oscil; 
        send("/oscil", my_oscil);
    }
    // t, turns on click
    if (key == 116) {
        0 => my_click; 
        send("/click", my_click);
    }
    // g, turns off click 
    if (key == 103) {
        10 => my_click; 
        send("/click", my_click);
    }
    // spacebar, shows instructions 
    if (key == 32) { 
        instructions();
    }

}

// send to all the players
fun void send(string param, float val) {
    for (int i; i < NUM_PLAYERS; i++) {
        c.send(players[i], param, val); 
    }
}

// main program, press spacebar to start
input();
