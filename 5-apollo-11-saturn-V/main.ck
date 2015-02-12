SndBuf apollo;
apollo.read(me.dir() + "apollo11saturnVaudio.wav");
apollo.rate(1.0);

Gain headphones;
Gain master;

// LiSaCluster stuff
LiSaCluster lc[3];
MultiPan p_lc[lc.cap()];
Gain lc_gain[lc.cap()];

// Reich stuff
Reich r[2];
MultiPan p_r[r.cap()];
Gain r_gain[r.cap()];

// FFTNoise
FFTNoise fn;
Gain fn_gain;

// midi control
NanoKontrol n;

// LiSaCluster setup
for (int i; i < lc.cap(); i++) {
    // lc independent gains
    lc_gain[i].gain(0.0);
    // lc sound chain
    apollo => lc[i] => lc_gain[i] => master => dac.chan(i);
    // lc initialize functions
    lc[i].fftSize(2048);
    lc[i].mfcc(1);
    lc[i].gain(0.0);
    lc[i].numClusters(4);
    lc[i].stepLength(100::ms);
    // alternate gain
    lc[i] => headphones;
}

// Reich setup
for (int i; i < r.cap(); i++) {
    // r independent gains
    r_gain[i].gain(0.0);
    // r sound chain
    apollo => r[i] => r_gain[i] => master => dac.chan(i);
    // r initialize functions
    r[i].randomPos(1);
    r[i].voices(16);
    r[i].bi(1);
    // alternate gain
    r[i] => headphones;
}

// FFTNoise setup
// fn independent gain
fn_gain.gain(0.0);
// fn sound chain
adc => fn => fn_gain => master => dac;
// alternate gain
fn => headphones;
// fn initlize function
fn.listen(1);

// headphone mix
headphones => dac.chan(5);

int master_gain;
int master_state;

lc.cap() => int lc_num;
int lc_vol[lc_num];
int lc_pos[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];

r.cap() => int r_num;
int r_vol[r_num];
int r_spd[r_num];
int r_latch[r_num];
int r_state[r_num];

int fn_vol;
int fn_state;

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
        // which cluster
        if (n.knob[i] != lc_pos[i]) {
            n.knob[i] => lc_pos[i];
            lc[i].cluster(lc_pos[i]/127.0);
        }
        // gain
        if (n.slider[i] != lc_vol[i]) {
            n.slider[i] => lc_vol[i];
            lc[i].gain(lc_vol[i]/127.0);
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
            if (r_state[i]) r_gain[i].gain(1.0);
            else r_gain[i].gain(0.0);
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
        if (fn_state) fn_gain.gain(1.0);
        else fn_gain.gain(0.0);
    }
    // gain
    if (n.slider[7] != fn_vol) {
        n.slider[7] => fn_vol;
        fn.gain(fn_vol/127.0);
    }
}

// master
fun void masterParams() {
    if (n.top[8] != master_state || n.slider[8] != master_gain) {
        n.top[8] => master_state;
        n.slider[8] => master_gain;
        if (master_state) master.gain(master_gain/127.0);
        else master.gain(0.0);
    }
}

// main loop
while (true) {
    lcParams();
    rParams();
    fnParams();
    masterParams();
    10::ms => now;
}
