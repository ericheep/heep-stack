// stasis_patterns.ck

// keyboard controls
KBHit kb;

// custom class
CalorkOsc c;

// set your sending address
c.myAddr("/eric");

// add one IP and address at a time, two string arguments
 c.addIp("10.0.0.3", "/jp");
// c.addIp("10.0.0.4", "/bruce");
// c.addIp("10.0.0.6", "/danny");
// c.addIp("10.0.0.7", "/dexter");

// you'll have to setup your parameters as an array of strings
c.setParams(["/gte", "/spd", "/len", "/frq", "/oct"]);

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
Math.random2(70,100) => float my_spd;
220 => float my_frq;
1.0 => float my_oct;
0.01 => float my_len;

// frequency max and min
240 => float frq_max;
200 => float frq_min;

// length max and min, scales spd
NUM_PLAYERS - 0.5 => float len_max;
0.01 => float len_min;

// storage for all sine stuffs
float gte[NUM_PLAYERS];
float oct[NUM_PLAYERS];
float len[NUM_PLAYERS];
float spd[NUM_PLAYERS];

// sound chain set up
for (int i; i < NUM_PLAYERS; i++) {
    sin[i] => env[i] => dac;
    sin[i].gain(0.7);

    // initializing arrays
    1.0 => oct[i];

}

// cycles backwards or forwards through the players
fun void cycle() {
    while (true) {  
        for (int i; i < NUM_PLAYERS; i++) {
            c.send(players[i], "/gte", 1);
            my_spd::ms => now;
        }
    }
}

// triggered every incoming osc msg, per player
fun void update(int idx) {
    // attack/release
    float ar;

    // receiving loop
    while (true) {
        c.e[idx] => now;

        // makes sound if gate is open,
        // ensures sound cannot change during an attack
        if (c.getParam(players[idx], "/gte") == 1) {
            len[idx] * spd[idx] => ar;
            env[idx].set(ar::ms, 0::ms, 1.0, ar::ms);
            env[idx].keyOn(); 
            ar::ms => now;
            env[idx].keyOff(); 
            c.resetParam(players[idx], "/gte");
        }
        else {
            // frequency parameters
            c.getParam(players[idx], "/oct") => oct[idx];
            c.getParam(players[idx], "/frq") * oct[idx] => sin[idx].freq;

            // speed parameters
            c.getParam(players[idx], "/len") => len[idx];
            c.getParam(players[idx], "/spd") => spd[idx];
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
        1 => begin;
        // initialize parameters
        send("/oct", my_oct);
        send("/frq", my_frq);
        for (int i; i < players.cap(); i++) {
            spork ~ update(i);
        }
        spork ~ cycle();
    }
    <<< " ", "" >>>;
    <<< "                  S T A S I S  P A T T E R N S ", "" >>>; 
    <<< " ", "" >>>;
    <<< "    [q] + speed    [w] + length    [e] + freq    [r] + octave", "" >>>; 
    <<< " ", "" >>>; 
    <<< "    [a] - speed    [s] - length    [d] - freq    [f] - octave", "" >>>; 
    <<< " ", "" >>>; 
}

// keyboard actions
fun void action(int key) {
    // q, speeds up rotation
    if (key == 113) {
        if (my_spd > 4) {
            3 -=> my_spd;
        }
        send("/spd", my_spd);
    }
    // a, slows down rotation
    if (key == 97) {
        if (my_spd < 1000) {
            3 +=> my_spd;
        }
        send("/spd", my_spd);
    }
    // w, increases length 
    if (key == 119) {
        if (my_len < len_max) {
            0.01 +=> my_len; 
        }
        send("/len", my_len);
    }
    // w, decreases length
    if (key == 115) {
        if (my_len > len_min) {
            0.01 -=> my_len; 
        }
        send("/len", my_len);
    }
    // w, raises frequency 
    if (key == 101) {
        if (my_frq < frq_max) {
            1 +=> my_frq; 
        }
        send("/frq", my_frq);
    }
    // s, lowers frequency 
    if (key == 100) {
        if (my_frq >= frq_min) {
            1 -=> my_frq; 
        }
        send("/frq", my_frq);
    }
    // e, doubles octave
    if (key == 114) {
        2.0 *=> my_oct; 
        send("/oct", my_oct);
    }
    // d, doubles octave 
    if (key == 102) {
        if (my_oct> 1.0) {
            2.0 /=> my_oct; 
        }
        send("/oct", my_oct);
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
        10::samp => now;
    }
}

// main program, press spacebar to start
<<< "Press spacebar to start:", "" >>>;
input();
