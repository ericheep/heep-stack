public class BlackmanHarrisEnv extends Chugen {
    // initial coefficients
    0.35875 => float a0;
    0.48829 => float a1;
    0.14128 => float a2;
    0.01168 => float a3;
    float w[0];
    float wUp[0];
    float wDown[0];

    int ramp_up, ramp_down, up, down;

    fun float[] calc(dur len) {
        (len/samp) $ int => int N;
        N * 2 => N;

        // window
        N => w.size;
        N/2 => wUp.size;
        N/2 => wDown.size;

        // blackman harris calculation
        for (int n; n < N; n++) {
            a0 => float t0;
            a1 * Math.cos((2 * pi * n)/N) => float t1;
            a2 * Math.cos((4 * pi * n)/N) => float t2;
            a3 * Math.cos((6 * pi * n)/N) => float t3; 

            t0 - t1 + t2 - t3 => w[n];
        }
       
        int mod;
        if (N % 2 == 0) {
            0 => mod;
        }
        else {
            1 => mod;
        }

        for (int i; i < w.cap()/2; i++) {
            w[i] => wUp[i];    
        }
        for (int i; i < w.cap()/2 + mod; i++) {
            w[i + (w.cap()/2 + mod)] => wDown[i]; 
        }
    }
    
    fun void rampUp() {
        1 => ramp_up;
        0 => up;
    }
    
    fun void rampDown() {
        1 => ramp_down;
        0 => down;
    }
    
    fun float tick (float in) {
        if (ramp_up) {
            if (up < wUp.cap()) {
                wUp[up] * in => in;        
                up++;
            }
            else {
                0 => ramp_up;
                0 => up;
            }
        }
        if (ramp_down) {
            if (down < wDown.cap()) {
                wDown[down] * in => in;        
                down++;
            }
            else {
                0 => ramp_down;
                0 => down;
            }
        }
        return in;
    }
}
