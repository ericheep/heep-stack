// FIR.ck
// finite impulse response filter

public class FIR {
  
    // amount of FIR things
    10 => int num;

    // arrays for each feature
    // float ch_avg[12][num];
    float cen_avg[num];
    float spr_avg[num];
    float crst_avg[num];

    public float fir(float x, string f) {
        // summation
        float sum;
        // scoots the entire array down, losing last value
        for (num - 2 => int i; i >= 0; i--) {
            if (f == "cen") cen_avg[i] => cen_avg[i + 1];
            if (f == "spr") spr_avg[i] => spr_avg[i + 1];
            if (f == "crst") crst_avg[i] => crst_avg[i + 1];
        }
        // places new value into first spot
        if (f == "cen") x => cen_avg[0];
        if (f == "spr") x => spr_avg[0];
        if (f == "crst") x => crst_avg[0];
        // sums the moving average vector
        for (int i; i < num; i++) {
            if (f == "cen") cen_avg[i] +=> sum;
            if (f == "spr") spr_avg[i] +=> sum;
            if (f == "crst") crst_avg[i] +=> sum;
        }
        // fir average
        return sum/num;
    }

    // returns average over a matrix, returns a filtered vector
    /* public float[] matFir(float X[]) {
        float avg[ch_avg.cap()]; 

        for (ch_avg[0].cap() - 2 => int i; i >= 0; i--) {
            for (int j; j < ch_avg.cap(); j++) {
                ch_avg[j][i] => ch_avg[j][i + 1];
            }
        }
      
        for (int i; i < X.cap(); i++) {
            X[i] => ch_avg[i][0];
        }

        for (int i; i < ch_avg.cap(); i++) {
            for (int j; j < ch_avg[0].cap(); j++) {
                ch_avg[i][j] +=> avg[i];
            }
            num /=> avg[i];
        }
        return avg;
    }
    */
}
