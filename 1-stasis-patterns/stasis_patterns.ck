// stasis_patterns.ck
// make a skinnier read out, add MORE PATTERNS
// keyboard controls
KBHit kb;

// custom class
CalorkOsc c;

// set your sending address
c.myAddr("/eric");
//10.0.0.8

// add one IP and address at a time, two string arguments
c.addIp("10.0.0.3", "/ed");
c.addIp("10.0.0.7", "/justin");
c.addIp("10.0.0.1", "/danny");

// you'll have to setup your parameters as an array of strings
c.setParams(["/g", "/s", "/l", "/f", "/o"]);

// grabs player list 
c.addrs @=> string players[];

// grabs number of players
players.cap() => int NUM_PLAYERS;

// enables listening
spork ~ c.recv();

// sets number of sin oscs to number of players
SinOsc sin[NUM_PLAYERS];
ADSR env[NUM_PLAYERS];

// press spacebar to start
int begin, sound;

// starting values
Math.random2(50, 60) => float my_spd;
2000 + Math.random2f(-4.0, 4.0) => float my_frq;
4.0 => float my_oct;
0.25 => float my_len;

// frequency max and min
2100 => float frq_max;
1900 => float frq_min;

// length max and min, scales spd
NUM_PLAYERS - 0.5 => float len_max;
0.005 => float len_min;

// storage for all sine stuffs
float oct[NUM_PLAYERS];
float len[NUM_PLAYERS];
float spd[NUM_PLAYERS];
float frq[NUM_PLAYERS];

// sound chain set up
for (int i; i < NUM_PLAYERS; i++) {
    sin[i] => env[i] => dac;
    sin[i].gain(1.0/(NUM_PLAYERS + 1));

    // initializing arrays
    1.0 => oct[i];

}

// cycles backwards or forwards through the players
fun void cycle() {
    while (true) {  
        for (int i; i < NUM_PLAYERS; i++) {
            c.send(players[i], "/g", 1);
            my_spd::ms => now;
        }
    }
}

// triggered every incoming osc msg, per player
fun void update(int idx) {
    // attack/release
    len[idx] * spd[idx] => float ar;

    // receiving loop
    while (true) {
        c.e[idx] => now;

        // ensures sound cannot change during an attack
        if (c.getParam(players[idx], "/g") == 1) {
            frq[idx] => sin[idx].freq;
            env[idx].set(ar::ms, 0::ms, 1.0, ar::ms);
            env[idx].keyOn(); 
            ar::ms => now;
            env[idx].keyOff(); 
            c.resetParam(players[idx], "/g");
        }
        else {
            // frequency parameters
            c.getParam(players[idx], "/o") => oct[idx];
            c.getParam(players[idx], "/f") * oct[idx] => frq[idx];

            // speed parameters
            c.getParam(players[idx], "/l") => len[idx];
            c.getParam(players[idx], "/s") => spd[idx];
            len[idx] * spd[idx] => ar;
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
        // starts player cycles
        for (int i; i < players.cap(); i++) {
            spork ~ update(i);
        }
        spork ~ cycle();
        spork ~ score();
    }
    else {
        <<< " ", "" >>>;
        <<< "                          S T A S I S  P A T T E R N S ", "" >>>; 
        <<< " ", "" >>>;
        <<< "    [q] + speed    [w] + envelope length    [e] + fundamental    [r] + octave", "" >>>; 
        <<< " ", "" >>>; 
        <<< "    [a] - speed    [s] - envelope length    [d] - fundamental    [f] - octave", "" >>>; 
        <<< " ", "" >>>; 
        <<< " ", "" >>>; 
    }
}

// keyboard actions
fun void action(int key) {
    // q, speeds up rotation
    if (key == 113) {
        if (my_spd > 20) {
            if (my_spd > 500) {
                30 -=> my_spd;
            }
            if (my_spd <= 500 && my_spd > 150) {
                20 -=> my_spd;
            }
            if (my_spd <= 150 && my_spd > 50) {
                10 -=> my_spd;
            }
            if (my_spd <= 50) {
                2 -=> my_spd;
            }
        }
        send("/s", my_spd);
    }
    // a, slows down rotation
    if (key == 97) {
        if (my_spd < 1000) {
            if (my_spd > 500) {
                30 +=> my_spd;
            }
            if (my_spd <= 500 && my_spd > 150) {
                20 +=> my_spd;
            }
            if (my_spd <= 150 && my_spd > 50) {
                10 +=> my_spd;
            }
            if (my_spd <= 50) {
                2 +=> my_spd;
            }
        }
        send("/s", my_spd);
    }
    // w, increases length 
    if (key == 119) {
        if (my_len < len_max) {
            0.002 +=> my_len; 
        }
        send("/l", my_len);
    }
    // w, decreases length
    if (key == 115) {
        if (my_len > len_min) {
            0.002 -=> my_len; 
        }
        send("/l", my_len);
    }
    // w, raises frequency 
    if (key == 101) {
        if (my_frq < frq_max) {
            0.1 +=> my_frq; 
        }
        send("/f", my_frq);
    }
    // s, lowers frequency 
    if (key == 100) {
        if (my_frq >= frq_min) {
            0.1 -=> my_frq; 
        }
        send("/f", my_frq);
    }
    // e, doubles octave
    if (key == 114) {
        2.0 *=> my_oct; 
        send("/o", my_oct);
    }
    // d, doubles octave 
    if (key == 102) {
        if (my_oct> 1.0) {
            2.0 /=> my_oct; 
        }
        send("/o", my_oct);
    }
    if (key == 116 && sound == 0) {
        1 => sound;
        // initialize parameters
        send("/l", my_len);
        send("/s", my_spd);
        send("/o", my_oct);
        send("/f", my_frq);
    }
    // spacebar, shows instructions 
    if (key == 32) { 
        instructions();
    }
    10::ms => now;
}

// send to all the players
fun void send(string param, float val) {
    for (int i; i < NUM_PLAYERS; i++) {
        c.send(players[i], param, val); 
        10::samp => now;
    }
}

fun void score() {
    <<< " ", "" >>>;
    <<< "     Time           Direction", "" >>>; 
    <<< "     ----           ---------", "" >>>; 
    <<< "     0:00 - 0:45    Press [t] to sound your pulse at anytime within the first 45 seconds,", "" >>>;
    <<< "                    change your speed at will, but keep it between a fast and medium", "" >>>;
    45::second => now;
    <<< " ", "" >>>;
    <<< "     0:45 - 1:15    Continue to change your speed at will, but keep it between a fast to slow cycle,", "" >>>;
    <<< "                    if you lock into an interesting rhythm, feel free to let it ride", "" >>>;
    30::second => now;
    <<< " ", "" >>>;
    <<< "     1:15 - 1:45    There are no restrictions to the speed of your cycles, begin skewing", "" >>>;
    <<< "                    your fundamental, go up exactly one octave over the course of 30 seconds", "" >>>;
    30::second => now;
    <<< " ", "" >>>;
    <<< "     1:45 - 2:15    Decrease the length of your envelope to it's smallest length, move your speed to", "" >>>;
    <<< "                    a fast to very fast cycle, keep skewing your fundamental", "" >>>;
    45::second => now;
    <<< " ", "" >>>;
    <<< "     2:15 - 3:00    Continue slightly skewing your fundamental, and jump down exactly two octaves", "" >>>;
    <<< "                    over the course of the next 45 seconds, begin to slow your cycle carefully ", "" >>>;
    45::second => now; 
    <<< " ", "" >>>;
    <<< "     3:00 - 3:30    You should be in the same octave range as everybody else, increase the length of", "" >>>;
    <<< "                    your envelope and slow your speed to a slow to medium cycle", "" >>>;
    30::second => now;
    <<< " ", "" >>>;
    <<< "     3:30 - 5:00    This is a very long phase, continue to skew your fundamental, search for ", "" >>>;
    <<< "                    severe beatings and harsh dissonances; your speed should continue to slow", "" >>>;
    <<< "                    and the length of your envelope should continue to increase", "" >>>; 
    90::second => now;
    <<< " ", "" >>>;
    <<< "     5:00 - 5:45    Move down an octave only once during the next 45 seconds; continue to skew your,", "" >>>;
    <<< "                    fundamental, if your cycle is not already very very slow, adjust accordingly", "" >>>;
    45::second => now;
    <<< " ", "" >>>;
    <<< "     5:45 - 6:30    Quickly, move to a very fast cycle during the next 15 seconds, then hold", "" >>>;
    <<< "                    that speed for the rest of the phase", "" >>>;
    45::second => now;
    <<< " ", "" >>>;
    <<< "     6:30 - 7:00    Quickly, move to any speed during the next 10 seconds, then hold that speed", "" >>>; 
    <<< "                    for the rest of the phase", "" >>>;
    30::second => now;
    <<< " ", "" >>>;
    <<< "     7:00 - 7:30    Quickly, move to a new speed during the next 5 seconds, then hold that speed", "" >>>;
    <<< "                    for the rest of the phase, ", "" >>>;
    30::second => now;
    <<< " ", "" >>>;
    <<< "     7:30 - 8:30    You have full control over the next minute", "" >>>;
    60::second => now;
    <<< " ", "" >>>;
    <<< "     8:30 - 9:00    Move to a very slow speed, ponder your life choices", "" >>>;
    30::second => now;

    // fin
    for (int i; i < NUM_PLAYERS; i++) {
        sin[i].gain(0.0);
    }
}

// main program, press spacebar to start
<<< " ", "" >>>;
<<< "                          S T A S I S  P A T T E R N S ", "" >>>; 
<<< " ", "" >>>;
<<< "    [q] + speed    [w] + envelope length    [e] + fundamental    [r] + octave", "" >>>; 
<<< " ", "" >>>; 
<<< "    [a] - speed    [s] - envelope length    [d] - fundamental    [f] - octave", "" >>>; 
<<< " ", "" >>>; 
<<< "                              spacebar to begin", "" >>>;

input();
