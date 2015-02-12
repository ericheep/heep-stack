SndBuf apollo;
apollo.read(me.dir() + "apollo11saturnVaudio.wav");
apollo.rate(1.0);
<<< "~ here we go ~", "" >>>;

apollo => Gain headphones => dac.chan(5);
Gain master;

// LiSaCluster stuff
LiSaCluster lc[2];
lc.cap() => int lc_num;
float lc_gain[lc_num];

// midi control
NanoKontrol n;

// LiSaCluster setup
for (int i; i < lc_num; i++) {
    // lc independent gains
    lc_gain[i].gain(0.0);
    // lc sound chain
    apollo => lc[i];
    // lc initialize functions
    lc[i].fftSize(1024);
    lc[i].mfcc(1);
    lc[i].gain(0.0);
    lc[i].numClusters(4);
    lc[i].stepLength(50::ms);
    // alternate gain
    lc[i] => headphones;
    lc[i].pan(0.0);
}
spork ~ spinning(); 

fun void spinning() {
    float pan;
    while (true) {
        (pan + 0.001) % 2.0 => pan;
        for (int i; i < lc_num; i++) {
            lc[i].pan(pan - 1.0);
        }
        0.1::ms => now;
    }
}

int lc_vol[lc_num];
int lc_pos[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];

// LiSaCluster controls
fun void lcParams() {
    for (int i; i < lc_num; i++) {
        // active/inactive
        if (n.top[i] != lc_state[i]) {
            n.top[i] => lc_state[i];
            // turns on/off gain
            if (lc_state[i]) lc_gain[i].gain(1.0);
            else lc_gain[i].gain(0.0);
        }
        // gain
        if (n.slider[i] != lc_vol[i]) {
            n.slider[i] => lc_vol[i];
            lc[i].vol(lc_vol[i]/127.0);
        }
        // record
        if (n.bot[i] && lc_latch[i] == 0) {
            lc[i].play(0);
            lc[i].record(1);
            1 => lc_latch[i];
        }
        if (n.bot[i] == 0 && lc_latch[i]) {
            lc[i].record(0);
            lc[i].play(1);
            0 => lc_latch[i];
        }
    }
}

// main loop
while (true) {
    lcParams();
    //rParams();
    //fnParams();
    //masterParams();
    10::ms => now;
}
