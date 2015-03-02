// impurities.ck
// Eric Heep

62 => int num_partials;
30::second => dur middle_length;
0.25::second => dur wait_length;

[   16.0, 
    15.0, 
    14.0,      16.0, 
    13.0,      15.0, 
    12.0,      14.0,
    11.0,      13.0,
    10.0,      12.0,
     9.0,      11.0,
     8.0,      10.0,
     7.0,       9.0,
     6.0,       8.0,
     5.0,       7.0,
     4.0,       6.0,
     3.0,       5.0,
     2.0,       4.0,
     1.0,       3.0,
 2.0/2.0,       1.0,
 2.0/3.0,       2.0,
 2.0/4.0,   2.0/2.0,
 2.0/5.0,   2.0/3.0,
 2.0/6.0,   2.0/4.0,
 2.0/7.0,   2.0/5.0,
 2.0/8.0,   2.0/6.0,
 2.0/9.0,   2.0/7.0,
2.0/10.0,   2.0/8.0,
2.0/11.0,   2.0/9.0,
2.0/12.0,  2.0/10.0,
2.0/13.0,  2.0/11.0,
2.0/14.0,  2.0/12.0,
2.0/15.0,  2.0/13.0,
2.0/16.0,  2.0/14.0,
           2.0/15.0,
           2.0/16.0    ] @=> float partials[];

[ 105, 104, 103, 101, 100,  99,  97,  95,  
   93,  91,  88,  85,  81,  76,  69,  57,  
   50,  45,  41,  38,  35,  33,  31,  29,
   27,  26,  25,  23,  22,  21 ] @=> int pianoMidi[];

MagicSine sin[num_partials];
ExpEnv env[num_partials];
Pan2 pan[num_partials];

for (int i; i < num_partials; i++) {
    pan[i].pan(i/(num_partials * 2.0) - 1.0);
    sin[i] => env[i] => pan[i] => dac; 
    sin[i].freq(partials[i] * 220.0);
    env[i].set(4::second, 0::samp, 1.0, 2::second);
    env[i].setCurves(2, 0, 1.0/2.0);
}

MidiIn in[10];
MidiMsg msg;

MidiOut out[10];
MidiMsg pianoMsg;

"iConnectMIDI1" => string midi_in;
"iConnectMIDI1" => string midi_out;

int inPort, outPort;
int note[109];
int active[109];

int  partial_inc;

for (int i; i < in.size(); i++) {
    in[i].printerr(0);

    // open the device
    if (in[i].open(i)) {
        if (in[i].name() == midi_in) {
            i => inPort;
            <<< "Connected to", in[inPort].name(), "" >>>;
            in[inPort].open(inPort);
        }
    }
    else break;
}

for (int i; i < out.size(); i++) {
    out[i].printerr(0);

    // open the device
    if (out[i].open(i)) {
        if (out[i].name() == midi_out) {
            i => outPort;
            <<< "Connected to", out[outPort].name(), "" >>>;
            out[outPort].open(outPort);
        }
    }
    else break;
}

spork ~ receive();

fun void receive() {
    while (true) {
        in[inPort] => now;
        while (in[inPort].recv(msg)) {
            if (msg.data1 != 176) {
                midiTimer(msg.data2, msg.data3);
            }
        }
    }
}

fun void midiTimer(int num, int val) {
    val => note[num];
    if (note[num] > 0) {
        1 => active[num];
        spork ~ timer(num); 
    }
    if (note[num] == 0) {
        0 => active[num];
    }
}

fun void timer(int num) {
    now => time noteOn;
    while (active[num]) {
        1::samp => now;
        if (now - noteOn > wait_length) {
            partial_inc => int idx;

            <<< idx, "" >>>;
            partial_inc++;
            if (idx != 31 && idx != 30) {
                playSingle(idx);
                10::second => now; 
            }
            else if (idx == 31) { 
                for (int i; i < num_partials/2 - 1; i++) {
                    spork ~ playAll(i * 2);
                }
                middle_length => now; 
            }

            break;
        }
    }
}

fun void playSingle(int idx) {
    sin[idx].gain(0.8);
    Math.random2f(0.5,1.0)::second => dur attack;
    env[idx].attack(attack);
    env[idx].keyOn();    
    attack => now;

    Math.random2f(4.0, 7.0)::second => dur release;
    env[idx].release(release);
    env[idx].keyOff();    
    release => now; 
}

fun void playAll(int idx) {
    Math.random2f(0.0, 1.0) => float a;
    Math.random2f(0.0, 1.0) => float b;
    Math.random2f(0.0, 1.0) => float c;

    sort([a, b, c]) @=> float val[];
    
    (1.0 - val[0]) * middle_length => now;
    (val[0] - val[1]) * middle_length => dur attack;
    (val[1] - val[2]) * middle_length => dur release;

    sin[idx].gain(1.0);
    env[idx].attack(attack);
    env[idx].keyOn();    
    attack => now;
    if (idx != 15 && idx != 16) {
        pianoOut(idx/2, 1);
    }

    env[idx].release(release);
    env[idx].keyOff();    
    if (idx != 15 && idx != 16) {
        pianoOut(idx/2, 0);
    }
    release => now;
}

fun void pianoOut(int idx, int vel) {
    144 => pianoMsg.data1; 
    pianoMidi[idx] => pianoMsg.data2;
    vel => pianoMsg.data3;
    out[outPort].send(pianoMsg);
}

fun float[] sort (float x[]) {
    int idx[x.cap()];
    float out[x.size()];

    for (int i; i < x.cap(); i++) {
       int idx_max;
       float max;
       for (int j; j < x.cap(); j++) {
            if (x[j] >= max) {
                x[j] => max;
                j => idx_max;
            }
        }
        x[idx_max] => out[i];
        0 => x[idx_max];
    }

    return out;
}

while (true) {
    1::second => now;
}
