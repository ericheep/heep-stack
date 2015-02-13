SndBuf apollo;
apollo.read(me.dir() + "apollo11saturnVaudio.wav");
apollo.rate(1.0);
<<< "~ here we go ~", "" >>>;

apollo => Gain headphones => dac.chan(5);

// midi control
NanoKontrol n;

// 0, 1, lc
// 2, 3, reich
// 4, 5, sort
// 6, noise
// 7, gate 
// 8, main

// LiSaCluster ~~~~~~~~~~~~~~~~~~~~~~
LiSaCluster lc[2];
lc.cap() => int lc_num;
float lc_gain[lc_num];

// LiSaCluster setup
for (int i; i < lc_num; i++) {
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

int lc_vol[lc_num];
int lc_pos[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];

// Reich ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reich r[2];
MultiPan r_mp[r.size()];
r.cap() => int r_num;

// Reich setup
for (int i; i < r_num; i++) {
    // r sound chain
    apollo => r[i] => r_mp[i];
    // r initialize functions
    r[i].gain(0.0);
    // turning down volume of multipan 
    r_mp[i].vol(0.0);
    r[i].randomPos(1);
    r[i].voices(16);
    r[i].bi(1);
    // alternate gain
    r[i] => headphones;
}

int r_vol[r_num];
int r_spd[r_num];
int r_latch[r_num];
int r_state[r_num];

// Sort ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sort s[2];
MultiPan s_mp[s.size()];
s.size() => int s_num;

// Sort setup
for (int i; i < s_num; i++) {
    // s sound chain
    apollo => s[i] => s_mp[i];
    s[i] => headphones;
    // turning down volume of multipan 
    s_mp[i].vol(0.0);
}

int s_vol[s_num];
int s_state[s_num];
int s_latch[s_num];

// Gate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apollo => Gain g => MultiPan g_mp;

// Gate setup
int g_vol;
int g_state;

// FFTNoise ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apollo => FFTNoise fn => MultiPan fn_mp;

// FFTNoise setup 
fn => headphones;
fn_mp.vol(0.0);

int fn_vol;
int fn_state;

// automatic panning functions
spork ~ lcSpinning(); 
spork ~ sSpinning();

fun void lcSpinning() {
    float pan;
    while (true) {
        (pan + 0.001) % 2.0 => pan;
        lc[0].pan(pan - 1.0);
        lc[1].pan((pan - 1.0) * -1.0 + 1.0);
        lc_ms::ms => now;
    }
}

fun void sSpinning() {
    float pan;
    while (true) {
        (pan + 0.001) % 2.0 => pan;
        s_mp[0].pan(pan - 1.0);
        s_mp[1].pan((pan - 1.0) * -1.0 + 1.0);
        0.2::ms => now;
    }
}

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

// Sort controls
fun void sParams() {
    for (int i; i < s_num; i++) {
         // active/inactive
        if (n.top[i + lc_num + r_num] != s_state[i]) {
            n.top[i + lc_num + r_num] => s_state[i];
            // turns on/off gain
            if (s_state[i]) s_mp[i].vol(1.0);
            else s_mp[i].vol(0.0);
        }
        // gain
        if (n.slider[i + lc_num + r_num] != s_vol[i]) {
            n.slider[i + lc_num + r_num] => s_vol[i];
            s[i].gain(s_vol[i]/127.0);
        }
        // record
        if (n.bot[i + lc_num + r_num] && s_latch[i] == 0) {
        <<< i + lc_num + r_num >>>;
            s[i].play(0);
            s[i].record(1);
            1 => s_latch[i];
        }
        if (n.bot[i + lc_num + r_num] == 0 && s_latch[i]) {
            s[i].record(0);
            s[i].play(1);
            0 => s_latch[i];
        }
    }
}


// FFTNoise controls
fun void fnParams() {
    // active/inactive
    if (n.top[6] != fn_state) {
        n.top[6] => fn_state;
        // turns on/off gain
        if (fn_state) fn_mp.vol(1.0);
        else fn_mp.vol(0.0);
    }
    // gain
    if (n.slider[6] != fn_vol) {
        n.slider[6] => fn_vol;
        fn.gain(fn_vol/127.0);
        if (fn_vol == 0) fn.listen(0);
        else fn.listen(1);
    }
}

// Gate controls
fun void gParams() {
    // active/inactive
    if (n.top[7] != g_state) {
        n.top[7] => g_state;
        // turns on/off gain
        if (g_state) g_mp.vol(1.0);
        else g_mp.vol(0.0);
    }
    // gain
    if (n.slider[7] != g_vol) {
        n.slider[7] => g_vol;
        g.gain(g_vol/127.0);
    }
}

// main loop
while (true) {
    lcParams();
    rParams();
    fnParams();
    sParams();
    //masterParams();
    10::ms => now;
}
