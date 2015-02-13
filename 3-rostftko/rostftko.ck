NanoKontrol n;
ReadImage r[8];

[0, 2, 4, 6] @=> int l_jpg[];
[1, 3, 5, 7] @=> int r_jpg[];

Pan2 pl, pr;

for (int i; i < 4; i++) {
    r[l_jpg[i]] => pl;
    r[r_jpg[i]] => pr;
}

pl => dac;
pr => dac;

pl.pan(-1.0);
pr.pan(1.0);

int window_mag[r.cap()];
int window_offset[r.cap()];
int rate[r.cap()];
int phase[r.cap()];
int pause_latch[r.cap()];
-1 => int l_switch;
-1 => int r_switch;
int l_current, r_current;


["maroon_l.txt", "maroon_r.txt", 
 "orange_l.txt", "orange_r.txt", 
 "blue_l.txt", "blue_r.txt", 
 "red_l.txt", "red_r.txt"] @=> string pic[];

<<< "------------------------", "" >>>;
<<< "All images loaded, Ready!", "" >>>;

fun void jpgOrder() {
    if (n.top[0] == 127 && l_current != l_switch) {
        l_current => l_switch;
        l_jpg[l_current] => int l_which;
        
        r[l_which].load(pic[l_which], "/left", l_which);
        //r[l_which].play(1);
        r[l_which].rate((24.0 - rate[l_which]/127.0 * 24.0) + 1.0);

        n.slider[0]/127.0 => r[l_which].magnitude;
        <<< "Next:", l_current, "JPG:", l_which  >>>;
    }
    if (n.top[4] == 127 && r_current != r_switch) {
        r_current => r_switch;
        r_jpg[r_current] => int r_which;

        r[r_which].load(pic[r_which], "/right", r_which);
        //r[r_which].play(1);
        r[r_which].rate((24.0 - rate[r_which]/127.0 * 24.0) + 1.0);
        n.slider[4]/127.0 => r[r_which].magnitude;
        <<< "Next:", r_current, "JPG:", r_which >>>;
    }
}

fun void endCounter() {
    if (r[l_jpg[l_current]].end == 1) {
        r[l_jpg[l_current]] =< pl;
        l_current++;
    }
    if (r[r_jpg[r_current]].end == 1) {
        r[r_jpg[r_current]] =< pl;    
        r_current++;
    }
}

fun void windowControls() {
    l_jpg[l_current] => int l_which;
    r_jpg[r_current] => int r_which;
    
    if (n.slider[0] != window_mag[l_which]) {
        n.slider[0] => window_mag[l_which];
        window_mag[l_which]/127.0 => r[l_which].magnitude;
    }
    if (n.knob[0] != window_offset[l_which]) {
        n.knob[0] => window_offset[l_which];
        window_offset[l_which]/127.0 => r[l_which].windowOffset;
    }
    if (n.slider[4] != window_mag[r_which]) {
        n.slider[4] => window_mag[r_which];
        window_mag[r_which]/127.0 => r[r_which].magnitude;
    }
    if (n.knob[4] != window_offset[r_which]) {
        n.knob[4] => window_offset[r_which];
        window_offset[r_which]/127.0 => r[r_which].windowOffset;
    }
    
}

fun void ratePhaseControls() {
    l_jpg[l_current] => int l_which;
    r_jpg[r_current] => int r_which;

    if (n.slider[1] != rate[l_which]) {
        n.slider[1] => rate[l_which];
        (24.0 - rate[l_which]/127.0 * 24.0) + 1.0 => r[l_which].rate;
    }
    if (n.knob[1] != phase[l_which]) {
        n.knob[1] => phase[l_which];
        phase[l_which]/127.0 => r[l_which].phase;
    }
    if (n.slider[5] != rate[r_which]) {
        n.slider[5] => rate[r_which];
        (24.0 - rate[r_which]/127.0 * 24.0) + 1.0 => r[r_which].rate;
    }
    if (n.knob[5] != phase[r_which]) {
        n.knob[5] => phase[r_which];
        phase[r_which]/127.0 => r[r_which].phase;
    }
    if (n.top[1] > 0 && pause_latch[l_which] == 0) {
        r[l_which].pause(1);
        1 => pause_latch[l_which];
    }
    if (n.top[1] == 0 && pause_latch[l_which]) {
        r[l_which].pause(0);
        0 => pause_latch[l_which];
    }
    if (n.top[5] > 0 && pause_latch[r_which] == 0) {
        r[r_which].pause(1);
        1 => pause_latch[r_which];
    }
    if (n.top[5] == 0 && pause_latch[r_which]) {
        r[r_which].pause(0);
        0 => pause_latch[r_which];
    }
}

while (true) {
    endCounter();
    ratePhaseControls();
    windowControls();
    jpgOrder();
    10::ms => now;
}

