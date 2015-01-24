// 0. left to right, low to high
Binary bi[2];
bi[0].adsr(10::ms, 0::ms, 1.0, 10::ms);
bi[1].adsr(10::ms, 0::ms, 1.0, 10::ms);

16 => int max;
int bit[max];
for (int i; i < bit.cap(); i++) {
    Math.pow(2, i + 1) $ int => bit[i];
}


fun void increment(float frq, int whch) {
    for (int j; j < 12; j++) {
        for (int i; i < bit[j]; i++) {
            bi[whch].play(frq, i + 2, 1 + j, 0.04::second);
        }
    }
}
//increment(55, 1);

/*
bi[0].spread(-0.25, -0.2);
spork ~ increment(55, 0);
10::second => now;
bi[1].spread(0.25, 0.2);
spork ~ increment(54, 1);
15::second => now;
*/

bi[0].adsr(10::second, 0::ms, 0.6, 10::ms);
bi[0].rotate(-1.0, 1.0, 128.0);
spork ~ bi[0].play(220, 3, 1, 100::second);
20::second => now;
bi[1].spread(-0.25, 0.25);
bi[1].adsr(9::ms, 0::ms, 1.0, 9::ms);
spork ~ increment(55, 1);
90::second => now;

5::second => now;
bi[0].spread(-1.0, 0.0);
bi[0].adsr(10::ms, 0::ms, 1.0, 100::second);
spork ~ bi[0].play(220, Math.random2(bit[15], bit[14]), 1, 101::second);

bi[1].spread(0.0, 1.0);
bi[1].adsr(10::ms, 0::ms, 1.0, 10::second);
spork ~ bi[1].play(220, Math.random2(bit[14], bit[13]), 1, 101::second);

10::second => now;
bi[0].rotate(-1.0, 0.0, 0.25);
bi[1].rotate(0.0, 1.0, 0.25);

10::second => now;
bi[0].rotate(-1.0, 0.0, 0.50);
bi[1].rotate(0.0, 1.0, 0.50);
10::second => now;
bi[0].rotate(-1.0, 0.0, 1.0);
bi[1].rotate(0.0, 1.0, 1.0);
10::second => now;
bi[0].rotate(-1.0, 0.0, 2.0);
bi[1].rotate(0.0, 1.0, 2.0);
10::second => now;
bi[0].rotate(-1.0, 0.0, 4.0);
bi[1].rotate(0.0, 1.0, 4.0);
10::second => now;
bi[0].rotate(-1.0, 0.0, 8.0);
bi[1].rotate(0.0, 1.0, 8.0);
10::second => now;
bi[0].rotate(-1.0, 0.0, 16.0);
bi[1].rotate(0.0, 1.0, 16.0);
10::second => now;

bi[0].rotate(-1.0, 0.0, 32.0);
bi[1].rotate(0.0, 1.0, 32.0);
100::second=> now;

bi[0].adsr(45::second, 0::ms, 1.0, 10::ms);
bi[0].rotate(-1.0, 1.0, 4.0);
spork ~ bi[0].play(55, Math.random2(bit[15], bit[14]), 4, 100::second);
40::second => now;

/*bi[1].rotate(1.0, -1.0, 1.0);
bi[1].adsr(14::second, 0::ms, 1.0, 14::second);
spork ~ bi[1].play(440, Math.random2(bit[12], bit[11]), 1, 30.0::second);
40::second => now;

bi[1].rotate(1.0, -1.0, 1.5);
bi[1].adsr(10::second, 0::ms, 1.0, 10::second);
spork ~ bi[1].play(220, Math.random2(bit[6], bit[5]), 2, 50.0::second);
40::second => now;

bi[0].adsr(6::second, 0::ms, 1.0, 6::second);
spork ~ bi[0].play(70, Math.random2(bit[15], bit[14]), 4, 30::second);
20::second => now;

bi[1].rotate(1.0, -1.0, 2.0);
bi[1].adsr(4::second, 0::ms, 1.0, 4::second);
spork ~ bi[1].play(250, Math.random2(bit[14], bit[13]), 3, 24.0::second);
17::second => now;

bi[0].rotate(-1.0, 1.0, 0.5);
spork ~ bi[0].play(80, Math.random2(bit[12], bit[11]), 4, 30.0::second);
15::second => now;

bi[1].rotate(1.0, -1.0, 0.5);
spork ~ bi[1].play(70, Math.random2(bit[14], bit[13]), 3, 40.0::second);
*./
/*
20::second => now;
bi[1].spread(-0.25, 0.25);
spork ~ bi[1].play(440, Math.random2(bit[13], bit[14]), 2, 3::second);
1.5::second => now;
bi[1].spread(-0.5, 0.5);
1.5::second => now;
bi[0].rotate(-1.0, 1.0, 2.0);

bi[0].play(55, Math.random2(bit[14], bit[15]), 4, 8::second);
bi[0].rotate(-1.0, 1.0, 4.0);

bi[0].play(55, Math.random2(bit[14], bit[15]), 4, 8::second);
bi[0].rotate(-1.0, 1.0, 8.0);

bi[0].play(55, Math.random2(bit[14], bit[15]), 4, 8::second);
*/



while (true) {
    1::second => now;
}
