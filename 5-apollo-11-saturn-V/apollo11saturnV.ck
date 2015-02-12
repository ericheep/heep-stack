SndBuf apollo;
apollo.read(me.dir() + "apollo11saturnVaudio.wav");
apollo.rate(1.0);
<<< "~ here we go ~", "" >>>;

apollo => Gain headphones => dac.chan(5);

// midi control
NanoKontrol n;

// LiSaCluster stuff
LiSaCluster lc[2];
lc.cap() => int lc_num;
float lc_gain[lc_num];

// LiSaCluster setup
for (int i; i < lc_num; i++) {
    // lc independent gains
    // lc_gain[i].gain(0.0);
    // lc sound chain
    apollo => lc[i];
    // lc initialize functions
    lc[i].fftSize(1024);
    lc[i].mfcc(1);
    lc[i].vol(0.0);
    lc[i].numClusters(4);
    lc[i].stepLength(50::ms);
    // alternate gain
    lc[i] => headphones;
    lc[i].pan(0.0);
}

// Reich stuff
Reich r[2];
MultiPan r_mp[r.size()];

// Reich setup
for (int i; i < r.cap(); i++) {
    // r sound chain
    apollo => r[i] => r_mp[i];
    // r initialize functions
    r[i].gain(0.0);
    // sets state to zero
    r_mp[i].vol(0.0);
    r[i].randomPos(1);
    r[i].voices(16);
    r[i].bi(1);
    // alternate gain
    r[i] => headphones;
}

r.cap() => int r_num;
int r_vol[r_num];
int r_spd[r_num];
int r_latch[r_num];
int r_state[r_num];

// FFTNoise stuff 
apollo => FFTNoise fn => MultiPan fn_mp;

// FFTNoise setup 
fn => headphones;
fn_mp.vol(0.0);
fn.listen(1);

int fn_vol;
int fn_state;

spork ~ spinning(); 

fun void spinning() {
    float pan;
    while (true) {
        (pan + 0.001) % 2.0 => pan;
        lc[0].pan(pan - 1.0);
        lc[1].pan((pan - 1.0) * -1.0 + 1.0);
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
            if (lc_state[i]) lc[i].state(1.0);
            else lc[i].state(0.0);
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

// Reich controls
fun void rParams() {
    for (int i; i < r_num; i++) {
        // active/inactive
        if (n.top[i + lc_num] != r_state[i]) {
            n.top[i + lc_num] => r_state[i];
            // turns on/off gain
            if (r_state[i]) r_mp[i].vol(1.0);
            else r_mp[i].vol(0.0);
        }
        // speed
        if (n.knob[i + lc_num] != r_spd[i]) {
            n.knob[i + lc_num] => r_spd[i];
            r[i].speed(r_spd[i]/127.0 * 2.0);
        }
        // gain
        if (n.slider[i + lc_num] != r_vol[i]) {
            n.slider[i + lc_num] => r_vol[i];
            r[i].gain(r_vol[i]/127.0);
        }
        // record
        if (n.bot[i + lc_num] && r_latch[i] == 0) {
            r[i].play(0);
            r[i].record(1);
            1 => r_latch[i];
        }
        if (n.bot[i + lc_num] == 0 && r_latch[i]) {
            r[i].record(0);
            r[i].play(1);
            0 => r_latch[i];
        }
    }
}


// FFTNoise controls
fun void fnParams() {
    // active/inactive
    if (n.top[7] != fn_state) {
        n.top[7] => fn_state;
        // turns on/off gain
        if (fn_state) fn_mp.vol(1.0);
        else fn_mp.vol(0.0);
    }
    // gain
    if (n.slider[7] != fn_vol) {
        n.slider[7] => fn_vol;
        fn.gain(fn_vol/127.0);
    }
}

// main loop
while (true) {
    lcParams();
    rParams();
    fnParams();
    //masterParams();
    10::ms => now;
}
