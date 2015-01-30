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
// grabs number of players
players.cap() => int NUM_PLAYERS;
// sets number of sin oscs to number of players
SinOsc sin[NUM_PLAYERS];

// sound chain set up
for (int i; i < NUM_PLAYERS; i++) {
    sin[i] => dac;
    sin[i].gain(0.0);
}

// main program
while (true) {
    1::second => now; 
}


