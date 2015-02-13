// sines.ck
// core composition and logic for Binary Sines
// Eric Heep, CalArts Music Tech

Quneo q;
Binary b[2];

// primary sin octave, separated into 4
SinOsc sin[4];
CirclePan c[4];

for (int i; i < sin.cap(); i++) {
    sin[i] => c[i];
    sin[i].gain(0.0);
}

sin[0].freq(55.0);
sin[1].freq(220.0);
sin[2].freq(87.307058);
sin[3].freq(138.591315);


int section, random;
int gain[4];
int diaSwtch, stopSwtch, sectionSwtch, rCntr, modChck;
int qSwtch[16];
int buttonSwtch[4];
int cntrSlider[2];
int cntrVol[2];
int inc, fdr, amp, spd;
int slowSwtch, volSwtch, bInc, add, sys, playSwtch, playMode;
int circleOffset[2];
int circlePan[2];
float cntrOffset[2];

2 => int sinAdd;
1 => int whchBit;
500 => int offset;

[1, 0, 11, 10, 2, 0, 0, 9, 3, 0, 0, 8, 4, 5, 6, 7] @=> int grid[]; 

int bit[16];
for (int i; i < bit.cap(); i++) {
    Math.pow(2, i + 1) $ int => bit[i];
}

spork ~ sinPan();
spork ~ sinVol();

fun void sinVol() {
    while (true) {
        for (int i; i < sin.cap(); i++) {
            if (i < sinAdd) {
                if (amp != gain[i] && gain[i] < 128 && gain[i] >= 0) {
                    if (amp > gain[i]) {
                        gain[i] + 1 => gain[i];
                    }
                    if (amp < gain[i]) {
                        gain[i] - 1 => gain[i];
                    }
                    sin[i].gain(gain[i]/127.0 * 0.4);
                }
            }
        }
        if (gain[0] != volSwtch) {
            gain[0] => volSwtch;
            q.led(176, 4, gain[0]);
        }
        200::ms => now;		
    }
}

fun void sinPan() {
    while (true) {
        // modulos for rotations
        (inc + 1) % 2000 => inc;
        (offset + 1) % 2000 => offset;
        
        // rotates sin waves oppositely and symetrically with each other
        c[0].pan((inc - 1000) * 0.001);
        c[1].pan((offset - 1000) * 0.001);
        c[2].pan((offset - 1000) * -0.001);
        c[3].pan((inc - 1000) * -0.001);
        ((128 - spd) * 3)::samp => now;   
    }
}

fun void slowChange() {
    while (fdr != spd) {
        if (fdr > spd) {
            spd + 1 => spd;
        }
        if (fdr < spd) {
            spd - 1 => spd;
        }
        q.led(176, 5, spd);
        (spd + 127)::ms => now;
    }
}

fun void binaryCounter(int loc, int vel, int num, int sys, int sinCnt) {
    (bInc + 1) % 2 => bInc;
    bInc => int temp;
    num + 2 => int chk;
    110 * Math.random2f(0.9, 3.0) => float frq;
    //b[temp].gain(vel/127.0 * 0.5 + 0.5);
    //b[temp].adsr(10::ms, 10::ms, 1.0, 10::ms);
    bit[sys + 1] - bit[sys] => int total;
    float circle;
    if (section == 1) {
        if (playMode == 0) {
            b[0].off();
            0.1::second => now;
            //<<< grid[loc], loc, cntrOffset[0] * 80, grid[loc] * 2.0/12.0 - 1.0 >>>;
            q.led(144, loc * 2, 127);
            q.led(144, loc * 2 + 1, 127);
            
            //b[0].gain(0.5);
            b[0].adsr(10::second, 0::ms, 1.0, 10::second);
            b[0].rotate(grid[loc] * 2.0/12.0 - 1.0 - cntrOffset[0] * 80, (grid[loc] + 1.0) * 2.0/12.0 - 1.0 + cntrOffset[0] * 80, circlePan[0]/16);
            b[0].play(frq + 100, Math.random2(bit[whchBit], bit[whchBit - 1]), sinAdd, 25::second);
            q.led(128, loc * 2, 0);
            q.led(128, loc * 2 - 1, 0);
            
        }
        if (playMode == 1) {
            b[0].adsr(10::ms, 10::ms, 1.0, 10::ms);
            0.1::second => now;
            q.led(144, loc * 2, 50);
            q.led(144, loc * 2 + 1, 50);
            for (int i; i < total; i++) {
                if (bInc == temp) {
                    b[0].spread(grid[loc] * 2.0/12.0 - 1.0 - circle, (grid[loc] + 1.0) * 2.0/12.0 - 1.0 + circle);
                    b[0].play(frq, Math.random2(bit[sys], bit[sys + 1]), sinCnt, 0.1::second);
                }
            }
            q.led(128, loc * 2, 0);
            q.led(128, loc * 2 + 1, 0);
        }
    }
    if (section == 0) {
        0.1::second => now;
        b[temp].adsr(10::ms, 10::ms, 1.0, 10::ms);
        q.led(144, loc * 2, 50);
        q.led(144, loc * 2 + 1, 50);
        for (int i; i < total; i++) {
            circle + cntrOffset[temp] => circle;
            i/(total $ float) * 127.0 => float where; 
            b[temp].gain(cntrVol[temp]/127.0);
            if (random == 0 && section == 0) {
                if (add < chk) {
                    //<<< circle, cntrOffset[temp] >>>;
                    b[temp].spread(grid[loc] * 2.0/12.0 - 1.0 - circle, (grid[loc] + 1.0) * 2.0/12.0 - 1.0 + circle);
                    b[temp].play(frq, bit[sys] + i + 1, sinCnt, 0.1::second);
                    
                    // leds
                    q.led(176, temp + 10, where $ int);
                    q.led(144, whchBit * 2 - 2, 127);
                    q.led(144, sinAdd * 2 - 3, 127);
                }
            }
            if (random == 1 && section == 0) {
                if (add < chk && sectionSwtch == 0) {
                    b[temp].spread(grid[loc] * 2.0/12.0 - 1.0 - circle, (grid[loc] + 1.0) * 2.0/12.0 - 1.0 + circle);
                    b[temp].play(frq, Math.random2(bit[sys], bit[sys + 1]), sinCnt, 0.1::second);
                    
                    // leds
                    q.led(176, temp + 10, where $ int);
                    q.led(144, whchBit * 2 - 2, 127);
                    q.led(144, sinAdd * 2 - 3, 127);
                }
            }
        }
        q.led(128, loc * 2, 0);
        q.led(128, loc * 2 + 1, 0);
        q.led(176, temp + 10, 0);
    }
}

fun void buttons() {
    for (int i; i < 4; i++) {
        if (q.button[9 + i] > 0 && buttonSwtch[i] == 0) {
            1 => buttonSwtch[i];
            if (q.button[9]) {
                q.led(128, sinAdd * 2 - 3, 0);
                sinAdd++;
                q.led(144, sinAdd * 2 - 3, 127);
            }
            if (q.button[10] && sinAdd > 2) {
                q.led(128, sinAdd * 2 - 3, 0);
                sinAdd--;
                q.led(144, sinAdd * 2 - 3, 127);
            }
            if (q.button[11] && whchBit < 13) { 
                q.led(128, whchBit * 2 - 2, 0);
                whchBit++;
                q.led(144, whchBit * 2 - 2, 127);
            }
            if (q.button[12] && whchBit > 1) {
                q.led(128, whchBit * 2 - 2, 0);
                whchBit--;
                q.led(144, whchBit * 2 - 2, 127);
            }
        }
        if (q.button[9 + i] == 0 && buttonSwtch[i] == 1) {
            0 => buttonSwtch[i];
        }
    }
}

fun void slowCntrVol(int whch) {
    while (cntrSlider[whch] != cntrVol[whch]) {
        if (cntrSlider[whch] > cntrVol[whch]) {
            cntrVol[whch]++;
        }
        if (cntrSlider[whch] < cntrVol[whch]) {
            cntrVol[whch]--;
        }
        q.led(176, 9 - whch, cntrVol[whch]);
        if (section == 1) {
            cntrVol[whch]/127.0 => b[whch].gain;
        }
        (cntrVol[whch] + 127)::ms => now;
    }
}

fun void sliders() {
    if (q.slider[9] != amp) {
        q.slider[9] => amp;
    }
    if (q.slider[2] != cntrSlider[0]) {
        q.slider[2] => cntrSlider[0];
        spork ~ slowCntrVol(0);
    }
    if (q.slider[3] != cntrSlider[1]) {
        q.slider[3] => cntrSlider[1];
        spork ~slowCntrVol(1);
    }
    if (q.slider[4] != circleOffset[0]) {
        q.slider[4] => circleOffset[0];
        //circleOffset[0]/127.0 * 0.01 => cntrOffset[0];
        spork ~ slowCircle(0);
    }
    if (q.slider[5] != circleOffset[1]) {
        q.slider[5] => circleOffset[1];
        //circleOffset[1]/127.0 * 0.01 => cntrOffset[1];
        spork ~ slowCircle(1);
    }
    
}

fun void slowCircle(int whch) {
    while (circleOffset[whch] != circlePan[whch]) {
        if (circleOffset[whch] > circlePan[whch]) {
            circlePan[whch]++;
        }
        if (circleOffset[whch] < circlePan[whch]) {
            circlePan[whch]--;
        }
        q.led(176, 6 + whch, circlePan[whch]);
        (circlePan[whch] + 300)::ms => now;
        circlePan[whch]/127.0 * 0.01 => cntrOffset[whch];
    }
    
}

fun void pads() {
    for (int i; i < 16; i++) {
        if (q.pad[i] > 0 && qSwtch[i] == 0) {
            1 => qSwtch[i];
            add++;
            spork ~ binaryCounter(i, q.pad[i], add, whchBit, sinAdd);
        }
        if (q.pad[i] == 0 && qSwtch[i] == 1) {
            0 => qSwtch[i];
        }
    }
}

fun void events() {
    if (q.diamond > 0 && diaSwtch == 0) {
        (random + 1) % 2 => random;
        1 => diaSwtch;
    }
    if (q.diamond == 0 && diaSwtch == 1) {
        0 => diaSwtch;
    }
    if (q.stop > 0 && stopSwtch == 0) {
        section++;
        1 => stopSwtch;
    }
    if (q.stop == 0 && stopSwtch == 1) {
        0 => stopSwtch;
    }
    if (q.play > 0 && playSwtch == 0) {
        (playMode + 1) % 2 => playMode;
        1 => playSwtch;
    }
    if (q.play == 0 && playSwtch == 1) {
        0 => playSwtch;
    }
}

while (true) {
    if (q.fader != fdr) {
        q.fader => fdr;
        spork ~ slowChange();
    }
    events();
    sliders(); 
    buttons();
    pads();    
    if (section == 1 && sectionSwtch == 0) {

        1.5::second => now;
        0 => rCntr;
        sectionSwtch++;
        127 => cntrSlider[0] => cntrVol[0] => cntrSlider[1] => cntrVol[1];
        1.0 => b[0].gain; 
        1.0 => b[1].gain;
        b[0].adsr(10::ms, 0::ms, 1.0, 20::second);
        b[1].adsr(10::ms, 0::ms, 1.0, 20::second);
        //b[2].adsr(10::ms, 0::ms, 1.0, 20::second);
        b[0].rotate(-1.0, 1.0, 0);
        b[1].rotate(-1.0, 1.0, 0.5);
        //b[2].rotate(-1.0, 1.0, 2);
        spork ~ b[0].play(65, Math.random2(bit[15], bit[14]), 3, 30::second);
        spork ~ b[1].play(55, Math.random2(bit[15], bit[14]), 3, 4::minute);
        //spork ~ b[2].play(110, Math.random2(bit[15], bit[14]), 1, 120::second);
        //spork ~ b[1].play(440, Math.random2(bit[15], bit[14]), 1, 101::second);
    }
    1::ms => now;
}


