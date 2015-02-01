// FIR.ck
// matrix finite impulse response filter

public class FIR {
   
    float mv_avg[12][10];

    public float[] fir(float X[]) {
        float avg[mv_avg.cap()]; 


        // 12, 10
        <<< mv_avg.cap(),  mv_avg[0].cap() >>>;

        for (mv_avg[0].cap() - 2 => int i; i >= 0; i--) {
            for (int j; j < mv_avg.cap(); j++) {
                mv_avg[j][i] => mv_avg[j][i + 1];
            }
        }
      
        for (int i; i < X.cap(); i++) {
            X[i] => mv_avg[i][0];
        }

        for (int i; i < mv_avg.cap(); i++) {
            for (int j; j < mv_avg[0].cap(); j++) {
                mv_avg[i][j] +=> avg[i];
            }
            12.0 /=> avg[i];
        }

        return avg;
    }
}
