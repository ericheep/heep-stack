public class LiSaSort {

    3 => int num_mics;

    // two LiSa arrays, one per player
    LiSa top_mic[num_mics];
    LiSa bot_mic[num_mics];

    Pan2 left;
    Pan2 right;

    // intializing parameters
    for (int i; i < num_mics; i++) {
        adc => top_mic[i] => left;
        adc => bot_mic[i] => right;
        top_mic[i].loop(1);
        bot_mic[i].loop(1);
        top_mic[i].bi(1);
        bot_mic[i].bi(1);
    }

    // hard panning left and right
    left.pan(-1.0);
    right.pan(1.0);
  
    // chucking to dac
    left => dac;
    right => dac;

    // switch arrays, one per player
    int top_active[3];
    int bot_active[3];
 
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
        if (side == 0) {
            if (addr == "/top") {
                if (top_l_global[idx] > 0) {
                    (top_active[top_l_global[idx] - 1] + 1) % 2 => top_active[top_l_global[idx] - 1];
                    spork ~ topRecord(top_l_global[idx] - 1, top_active[top_l_global[idx] - 1], beat);
                }
            }
            if (addr == "/bot") {
                if (bot_l_global[idx] > 0) {
                    (bot_active[bot_l_global[idx] - 1] + 1) % 2 => bot_active[bot_l_global[idx] - 1];
                    spork ~ botRecord(bot_l_global[idx] - 1, bot_active[bot_l_global[idx] - 1], beat);
                }
            }
        }
        if (side == 1) {
            if (addr == "/top") {
                if (top_r_global[idx] > 0) {
                    (top_active[top_r_global[idx] - 1] + 1) % 2 => top_active[top_r_global[idx] - 1];
                    spork ~ topRecord(top_r_global[idx] - 1, top_active[top_r_global[idx] - 1], beat);
                }
            }
            if (addr == "/bot") {
                if (bot_r_global[idx] > 0) {
                    (bot_active[bot_r_global[idx] - 1] + 1) % 2 => bot_active[bot_r_global[idx] - 1];
                    spork ~ botRecord(bot_r_global[idx] - 1, bot_active[bot_r_global[idx] - 1], beat);
                }
            }
        }
    }

    
    private void topRecord(int mode, int mod, dur beat) {
        // only records last fourth of a beat
        top_mic[mode].duration(beat);
        beat/4.0 * 3 => now;
        top_mic[mode].record(1);
        beat/4.0 => now;
        top_mic[mode].record(0);

        top_mic[mode].loopEnd(beat/4.0);
        top_mic[mode].play(1);

        while (top_active[mode] == mod) {
            top_mic[mode].rampUp(beat/8.0);
            beat/2.0 - beat/8.0 => now;
            top_mic[mode].rampDown(beat/8.0);
            beat/8.0 => now;
        }

        top_mic[mode].play(0);
    }

    private void botRecord(int mode, int mod, dur beat) {
        // only records last fourth of a beat
        bot_mic[mode].duration(beat);
        beat/4.0 * 3 => now;
        bot_mic[mode].record(1);
        beat/4.0 => now;
        bot_mic[mode].record(0);

        bot_mic[mode].loopEnd(beat/4.0);
        bot_mic[mode].play(1);

        while (bot_active[mode] == mod) {
            bot_mic[mode].rampUp(beat/8.0);
            beat/2.0 - beat/8.0 => now;
            bot_mic[mode].rampDown(beat/8.0);
            beat/8.0 => now;
        }
        bot_mic[mode].play(0);
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
