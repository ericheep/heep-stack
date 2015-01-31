CalorkOsc c;

// set your sending address
c.myAddr("/eric");

// add one IP and address at a time, two string arguments
c.addIp("169.254.87.91", "/justin");
c.addIp("169.254.223.167", "/danny");
c.addIp("169.254.207.86", "/mike");
c.addIp("169.254.74.231", "/shaurjya");
c.addIp("169.254.24.203", "/ed");

// you'll have to setup your parameters as an array of strings
c.setParams(["/on", "/off", "/vols", "/harm", "/speed", "/double", "/chaos"]);

// grabs player list 
c.addrs @=> string players[];
players << c.my_addr;

// grabs number of players
players.cap() => int NUM_PLAYERS;

// sets number of sin oscs to number of players
SinOsc sin[NUM_PLAYERS];
Gain gate[NUM_PLAYERS];

// sound chain set up
for (int i; i < NUM_PLAYERS; i++) {
    sin[i] => gate[i] => dac;
    sin[i].gain(1.0);
    gate[i].gain(0.0);;
    <<< players[i], "" >>>;
}

// cycles backwards or forwards through the players
fun void cycle() {
    while (true) {  
        for (int i; i < players.cap(); i++) {
            spin(i, "/off");
            spin((i + 1) % NUM_PLAYERS, "/on"); 
            update();
            100::ms => now;
        }
    }
}

// triggered every cycle 
fun void update() {
    // one less, so not to trigger yourself
    for (int i; i < players.cap() - 1; i++) {
        c.getParam(players[i], "/on") => gate[i].gain;
        c.getParam(players[i], "/off") => gate[i].gain;
        c.getParam(players[i], "/freq") => sin[i].gain;
    }
}

fun void local(string msg) {
    if (msg == "/off") {
        gate[NUM_PLAYERS - 1].gain(0.0);
    }
    else if (msg == "/on") {
        gate[NUM_PLAYERS - 1].gain(1.0);
    }
}

// 
fun void spin(int idx, string msg) {
    if (players[idx] == c.my_addr) {
        if (msg == "/off") {
            gate[NUM_PLAYERS - 1].gain(0.0);
        }
        else if (msg == "/on") {
            gate[NUM_PLAYERS - 1].gain(1.0);
        }
    }
    else {
        c.send(players[idx], msg, 0);
    }
}

spork ~ cycle();
spork ~ event();

// main program
while (true) {
    1::second => now; 
}


