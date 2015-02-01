// spinning-sines.ck

// keyboard controls
KBHit kb;

// custom class
CalorkOsc c;

// set your sending address
c.myAddr("/eric");

// add one IP and address at a time, two string arguments
c.addIp("169.254.87.91", "/justin");
//c.addIp("169.254.223.167", "/danny");
//c.addIp("169.254.207.86", "/mike");
//c.addIp("169.254.74.231", "/shaurjya");
//c.addIp("169.254.24.203", "/ed");

// you'll have to setup your parameters as an array of strings
c.setParams(["/gate", "/freq"]);

// grabs player list 
c.addrs @=> string players[];

// grabs number of players
players.cap() => int NUM_PLAYERS;

// enables listening
spork ~ c.recv();

// sets number of sin oscs to number of players
SinOsc sin[NUM_PLAYERS];
Gain gate[NUM_PLAYERS];

// sine parameters
500 => float spd; 
50 => float my_fnd;
10 => float my_hrm;

// storage for all sine stuffs
float hrm[NUM_PLAYERS]; 
float fnd[NUM_PLAYERS]; 

// sound chain set up
for (int i; i < NUM_PLAYERS; i++) {
    sin[i] => dac;
    sin[i].gain(0.0);
}

// cycles backwards or forwards through the players
fun void cycle() {
    while (true) {  
        for (int i; i < NUM_PLAYERS; i++) {
            c.send(players[i], "/gate", 0);
            c.send(players[(i + 1) % NUM_PLAYERS], "/gate", 0.4); 
            spd::ms => now;
        }
    }
}

// triggered every cycle 
fun void update() {
    while (true) {
        c.e => now;
        for (int i; i < NUM_PLAYERS; i++) {
            c.getParam(players[i], "/gate") => sin[i].gain;
            c.getParam(players[i], "/freq") => sin[i].freq;
        }
         <<< c.getParam("/eric", "/freq"), c.getParam("/eric", "/gate") >>>;
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
    <<< " ", "" >>>;
    <<< "             S P I N N I N G    S I N E S         ", "" >>>; 
    <<< " ", "" >>>;
    <<< "    [q] + speed    [w] + partial    [e] + fundamental ", "" >>>; 
    <<< " ", "" >>>; 
    <<< "    [a] - speed    [s] - partial    [d] - fundamental ", "" >>>; 
    <<< " ", "" >>>; 
}

// keyboard actions
fun void action(int key) {
    // q, speeds up rotation
    if (key == 113) {
        if (spd > 10) {
            1 -=> spd;
        }
    }
    // a, slows down rotation
    if (key == 97) {
        if (spd < 1000) {
            1 +=> spd;
        }
    }
    // w, raises harmonic
    if (key == 119) {
        if (my_hrm < 10) {
            1 +=> my_hrm; 
        }
        send("/freq", my_hrm * my_fnd);
    }
    // s, lowers harmonic
    if (key == 115) {
        if (my_hrm >= 1) {
            1 -=> my_hrm; 
        }
        send("/freq", my_hrm * my_fnd);
    }
    // e, skews frequency up
    if (key == 101) {
        if (my_fnd < 55) {
            1 +=> my_fnd; 
        }
        send("/freq", my_hrm * my_fnd);
    }
    // d, skews frequency down
    if (key == 100) {
        if (my_fnd > 25) {
            1 -=> my_fnd; 
        }
        send("/freq", my_hrm * my_fnd);
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

// main program
spork ~ update();
spork ~ input();
cycle();
