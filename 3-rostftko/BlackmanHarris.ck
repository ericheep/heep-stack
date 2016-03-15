public class BlackmanHarris {
    // initial coefficients
    0.35875 => float a0;
    0.48829 => float a1;
    0.14128 => float a2;
    0.01168 => float a3;

    fun float[] calc(int N) {
        // window
        float w[N];

        // blackman harris calculation
        for (int n; n < N; n++) {
            a0 => float t0;
            a1 * Math.cos((2 * pi * n)/N) => float t1;
            a2 * Math.cos((4 * pi * n)/N) => float t2;
            a3 * Math.cos((6 * pi * n)/N) => float t3; 

            t0 - t1 + t2 - t3 => w[n];
        }

        return w;
    }
}
