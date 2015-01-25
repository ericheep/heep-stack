public class LiSaSort {

    // two LiSa arrays, one per player
    LiSa top_mic[3];
    LiSa bot_mic[3];

    // switch arrays, one per player
    int top_switch[3];
    int bot_switch[3];
 
    // global arrays for top
    int top_l_global[0];
    int top_r_global[0];

    // global arrays for bottom 
    int bot_l_global[0];
    int bot_r_global[0];

    // gets arrays ready for evaluation
    public void prime(string addr, int l_arr[], int r_arr[], int l_ref[], int r_ref[]) {
        if (addr == "/top") {
            l_arr.cap() => top_l_global.size;
            r_arr.cap() => top_r_global.size;
        }
        if (addr == "/bot") {
            l_arr.cap() => bot_l_global.size;
            r_arr.cap() => bot_r_global.size;
        }

        for (int i; i < l_ref.cap(); i++) {
            for (int j; j < l_ref.cap(); j++) {
                if (j == l_arr[i]) {
                    if (addr == "/top") {
                        l_ref[j] => top_l_global[i];
                    }
                    if (addr == "/bot") {
                        l_ref[j] => bot_l_global[i];
                    }
                }
            }
        }

        for (int i; i < r_ref.cap(); i++) {
            for (int j; j < r_ref.cap(); j++) {
                if (j == r_arr[i]) {
                    if (addr == "/top") {
                        r_ref[j] => top_r_global[i];
                    }
                    if (addr == "/bot") {
                        r_ref[j] => bot_r_global[i];
                    }
                }
            }
        }
    }

    public void eval(string addr, int idx, dur beat, int side) {
        if (idx % 2 == 0) {
            if (side == 0) {
                if (addr == "/top") {
                    if (top_l_global[idx/2] > 0) {
                        spork ~ record(top_l_global[idx/2]);
                    }
                }
                if (addr == "/bot") {
                    if (bot_l_global[idx/2] > 0) {
                        spork ~ record(bot_l_global[idx/2]);
                    }
                }
            }
            if (side == 1) {
                if (addr == "/top") {
                    if (top_r_global[idx/2] > 0) {
                        spork ~ record(top_r_global[idx/2]);
                    }
                }
                if (addr == "/bot") {
                    if (bot_r_global[idx/2] > 0) {
                        spork ~ record(bot_r_global[idx/2]);
                    }
                }
            }
        }
    }

    private void record(int mode) {
        <<< mode >>>;
    }

    // prints contents
    public void printArrays(int ref_prv[], int prv[], int ref_cur[], int cur[]) {
         "[" => string print;
         for (int i; i < prv.cap(); i++) {
            prv[i] + "" +=> print;
            if (i != prv.cap() - 1) {
                ", " +=> print;
            }
        }
        "] [" +=> print;
        for (int i; i < ref_prv.cap(); i++) {
            for (int j; j < ref_prv.cap(); j++) {
                if (j == prv[i]) {
                    ref_prv[j] + "" +=> print;
                }
            }
            if (i != ref_prv.cap() - 1) {
                ", " +=> print;
            }
        }
        "] || [" +=> print;
         for (int i; i < cur.cap(); i++) {
            cur[i] + "" +=> print;
            if (i != cur.cap() - 1) {
                ", " +=> print;
            }
        }
        "] [" +=> print;
        for (int i; i < ref_cur.cap(); i++) {
            for (int j; j < ref_cur.cap(); j++) {
                if (j == cur[i]) {
                    ref_cur[j] + "" +=> print;
                }
            }
            if (i != ref_cur.cap() - 1) {
                ", " +=> print;
            }
        }
        "]" +=> print;
        <<< print, "" >>>;
    }


}
