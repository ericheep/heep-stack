// SinTest.ck

public class SinTest {

    SinOsc sin[33];

    for (int i; i < 33; i++) {
        sin[i] => dac;
        sin[i].freq(Std.mtof(i + 44));
        sin[i].gain(0.0);
    }
    
    fun void listen(float q[], dur hop) {
        for (int i; i < 33; i++) {
            if (q[i] > 0.001) {
                spork ~ play(q[i], i, hop);
            }
        }
    }

    fun void play(float amp, int which, dur hop) {
        sin[which].gain(amp * 10);
        hop => now;
        sin[which].gain(0.0);
    }
}
