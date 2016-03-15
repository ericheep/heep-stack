SndBuf apollo;
apollo => Gain headphones => dac.chan(5);

// starting the piece with spacebar
Hid hi;
HidMsg msg;
if (!hi.openKeyboard(0)) me.exit();

int begin;

fun void hereWeGo() {
    while (begin == 0) {
        hi => now;
        while (hi.recv(msg)) {
            if (msg.isButtonDown()) {
                if (msg.ascii == 32 && begin == 0) {
                    apollo.read(me.dir() + "apollo11saturnVaudio.wav");
                    1 => begin;
                    <<< "~ here we go ~", "" >>>;
                }
            }
        }
    }
}

// midi control
NanoKontrol n;
Quneo q;
<<< "- press spacebar to begin -", "">>>;

// Nano
// 0, 1, lc
// 2, 3, reich
// 4, 5, sort
// 6, noise
// 7, gate 
// 8, main

// Quneo
// pads, spatialized micro/phonogene

// NanoKontrol Classes ~~~~~~~~~~~~~~~~~~~~~~+=+

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
    lc[i].vol(0.0);
    lc[i].numClusters(5);
    lc[i].stepLength(50::ms);
    // alternate gain
    lc[i] => headphones;
    lc[i].pan(0.0);
}

// features for first cluster
lc[0].centroid(1);
lc[0].crest(1);

// features for second cluster
lc[1].hfc(1);
lc[1].subbandCentroids(1);

int lc_vol[lc_num];
int lc_pos[lc_num];
int lc_latch[lc_num];
int lc_state[lc_num];
int lc_pan[lc_num];
float lc_spin[lc_num];

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
    r[i].randomPos(1);
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
int s_pan[s_num];
float s_mod[s_num];
float s_spin[s_num];

// FFTNoise ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apollo => FFTNoise fn => MultiPan fn_mp;

// FFTNoise setup 
fn => headphones;
fn_mp.vol(0.0);

int fn_vol;
int fn_state;
int fn_pan;
float fn_chance;

// Gate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apollo => Gain g => MultiPan g_mp;
g.gain(0.0);
g_mp.vol(0.0);

// Gate setup
int g_vol;
int g_state;
int g_pan;
float g_spin;

// Quneo Classes ~~~~~~~~~~~~~~~~~~~~~~+=+

// Micro
Micro m[12];
Gain m_g[m.size()];
m.size() => int m_num;

// array for outside loops
[ 1,  0,  4,
  8, 12, 13, 
 14, 15, 11,
  7,  3,  2] @=> int m_q[]; 

[ 0,  0,  0,
  1,  1,  1,
  3,  3,  3,
  4,  4,  4] @=> int m_chan[];

for (int i; i < m_num; i++) {
    apollo => m[i] => m_g[i] => dac.chan(m_chan[i]);
    m[i].loopTime(50::ms * ((i % 3 ) + 1));
    m[i].rampTime(20::ms);
}

int m_latch[m_num];
int m_vol;

// Special Micro
MicroPan sm[4]; 
Gain sm_g[sm.size()];
sm.size() => int sm_num;

[ 5,  6,
  9, 10] @=> int sm_q[];

[-0.5, 0.0, 0.5, 1.0, -1.0] @=> float amy[];
[-0.5, 0.0, -0.5, 0.0, 0.5, 0.0, 0.5, 1.0, 0.5, 1.0] @=> float rodrigo[];
[0.5, 0.5, 0.0, -0.5, -0.5, 0.0, 1.0, 1.0, 0.0] @=> float eric[];

for (int i; i < sm_num; i++) {
    apollo => sm[i];
    sm[i].loopTime(100::ms);
    sm[i].rampTime(20::ms);
}

sm[0].spatialArray(amy);
sm[1].spatialArray(rodrigo);
sm[2].spatialArray(eric);
int sm_latch[sm_num];
int sm_lock;
int sm_lock_latch;

// NanoKontrols ~~~~~~~~~~~~~~~~~~~~~~~~

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
        if (n.knob[i] != lc_pan[i]) {
            n.knob[i] => lc_pan[i];
            lc_pan[i]/127.0 => lc_spin[i];
        }
    }
}

// LiSaCluster panning
fun void lcSpin(int idx) {
    float mod, pan;
    while (true) {
        if (idx) {
            (mod + lc_spin[idx] * .0001) % 2.0 => mod;
            mod - 1.0 => pan;
        }
        else {
            (mod + lc_spin[idx] * .0001) % 2.0 => mod;
            (mod * -1.0 + 1.0) => pan;
        }
        lc[idx].pan(pan);
        0.1::ms => now;
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

// Reich panning
fun void rSpin() {
    float pan;
    while (true) {
        (pan + 0.000001) % 2.0 => pan;
        r_mp[0].pan(pan - 1.0);
        r_mp[1].pan((pan - 1.0) * -1.0 + 1.0);
        0.1::ms => now;
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
        // pan
        if (n.knob[i + lc_num + r_num] != s_pan[i]) {
            n.knob[i + lc_num + r_num] => s_pan[i];
            (s_pan[i]/127.0) * 0.01 => s_spin[i];
        }
        // record
        if (n.bot[i + lc_num + r_num] && s_latch[i] == 0) {
            s[i].play(0);
            s[i].record(1);
            1 => s_latch[i];
        }
        if (n.bot[i + lc_num + r_num] == 0 && s_latch[i]) {
            s[i].record(0);
            s[i].play(1);
            0 => s_latch[i];
        }
        // spin 
        if (i == 0 && s_pan[i] != 0.0) {
            (s_mod[i] + s_spin[i]) % 1.0 => s_mod[i];
            s_mp[i].pan(s_mod[i] * 2.0 - 1.0);
        }
        else if (i == 1 && s_pan[i] != 0.0) {
            (s_mod[i] + s_spin[i]) % 1.0 => s_mod[i];
            s_mp[i].pan((s_mod[i] * -1.0 + 1.0) * 2.0 - 1.0);
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
    if (n.knob[6] != fn_pan) {
        n.knob[6] => fn_pan;
        fn_pan/127.0 => fn_chance;

    }
}

// FTTNoise panning
fun void fnSpin() {
    float pan;
    while (true) {
        Math.random2f(0.0, 1.0) => pan;
        if (fn_chance > Math.random2f(0.0, 1.0)) {
            fn_mp.pan(pan * 2.0 - 1.0); 
        }
        (500 * (fn_chance * -1.0 + 1.0))::ms + 100::ms => now;
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
    if (n.knob[7] != g_pan) {
        n.knob[7] => g_pan; 
        if (g_pan == 0) {
            g_mp.pan(0.0);
        }
        g_pan/127.0 => g_spin;
    }
}

// Gate panning
fun void gSpin() {
    float pan;
    while (true) {
        if (g_spin){
            (g_spin * .001 + pan) % 1.0 => pan;
            g_mp.pan(pan * 2.0 - 1.0);
        }
        1::ms => now;
    }
}

// Micro and Special Micro controls
fun void mParams() {
    if (q.fader != m_vol) {
        q.fader => m_vol;
        for (int i; i < m_num; i++) {
            m_vol/127.0 => m_g[i].gain;
        }
        for (int i; i < sm_num; i++) {
            m_vol/127.0 => sm[i].vol;
        }
    }
    for (int i; i < m_num; i++) {
        if (sm_lock) {
            q.led(144, m_q[i] * 2, 127);
            if (m_latch[i]) {
                q.led(144, m_q[i] * 2 + 1, 127);
            }
        }
        if (q.pad[m_q[i]] > 0 && m_latch[i] == 0) {
            m[i].gain(q.pad[m_q[i]]/127.0);
            m[i].loop(1); 
            1 => m_latch[i];
        }
        if (sm_lock == 0) {
            if (q.pad[m_q[i]] == 0 && m_latch[i]) {
                m[i].loop(0);
                0 => m_latch[i];
            }
        }
    }
    for (int i; i < sm_num; i++) {
        if (sm_lock) {
            q.led(144, sm_q[i] * 2, 127);
            if (sm_latch[i]) {
                q.led(144, sm_q[i] * 2 + 1, 127);
            }
        }
        if (q.pad[sm_q[i]] > 0 && sm_latch[i] == 0) {
            sm[i].micVol(q.pad[sm_q[i]]/127.0);
            sm[i].loop(1);
            1 => sm_latch[i];
        }
        if (sm_lock == 0) {
            if (q.pad[sm_q[i]] == 0 && sm_latch[i]) {
                sm[i].loop(0);
                0 => sm_latch[i];
            }
        }
    }
    if (q.stop > 0 && sm_lock_latch == 0) {
        (sm_lock + 1) % 2 => sm_lock;
        1 => sm_lock_latch; 
        if (sm_lock == 0) {
            for (int i; i < 32; i++) {
                q.led(144, i, 0);
            }
        }
    }
    if (q.stop == 0 && sm_lock_latch) {
        0 => sm_lock_latch;
    }
}

// main loop
fun void params() {
    while (true) {
        lcParams();
        rParams();
        fnParams();
        sParams();
        gParams();
        mParams();
        10::ms => now;
    }
}

// NOTE: maybe incorporate these spin functions into main param functions
// less sporking, easier calc, maybe, like Sort

// automatic panning functions
spork ~ lcSpin(0); 
spork ~ lcSpin(1); 
spork ~ rSpin();
spork ~ fnSpin();
spork ~ gSpin();
spork ~ hereWeGo();
params();


