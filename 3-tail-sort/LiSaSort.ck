public class LiSaSort {
    ArrayFunctions a;
    2 => int num_mics;
    4 => int modes;

    // two LiSa arrays, one per player
    LiSa mic[num_mics][2];

    Pan2 left;
    Pan2 right;

    // intializing parameters
    for (int i; i < num_mics; i++) {
        adc => mic[i][0] => left;
        adc => mic[i][1] => right;
        mic[i][0].loop(1);
        mic[i][1].loop(1);
        mic[i][0].bi(1);
        mic[i][1].bi(1);
    }

    // hard panning left and right
    left.pan(-1.0);
    right.pan(1.0);
  
    // chucking to dac
    left => dac;
    right => dac;

    // switch arrays, one per player
    int active[modes][2];
 
    // global arrays for top
    int top_l_global[0];
    int top_r_global[0];

    // global arrays for bottom 
    int bot_l_global[0];
    int bot_r_global[0];

    // index arrays
    int top_l_idx[][];
    int top_r_idx[][];
    int bot_l_idx[][];
    int bot_r_idx[][];

    // distance arrays
    int top_l_dist[][];
    int top_r_dist[][];
    int bot_l_dist[][];
    int bot_r_dist[][];

    // creates arrays for sending, creates a second array for distances
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
        
        if (addr == "/top") {
            // returns index positions of notes 
            a.index(top_l_global, modes) @=> top_l_idx;
            a.index(top_r_global, modes) @=> top_r_idx;
            // returns distances of each note in each mode
            a.distance(top_l_idx, top_r_idx, modes) @=> top_l_dist;
            a.distance(top_r_idx, top_l_idx, modes) @=> top_r_dist;
        }

        if (addr == "/bot") {
            // returns index positions of notes 
            a.index(bot_l_global, modes) @=> bot_l_idx;
            a.index(bot_r_global, modes) @=> top_r_idx;
            // returns distances of each note in each mode
            a.distance(bot_l_idx, bot_r_idx, modes) @=> bot_l_dist;
            a.distance(bot_r_idx, bot_l_idx, modes) @=> bot_r_dist;
        }
    }

    public void eval(string addr, int idx, dur beat, int side) {
        int d;
        if (side == 0) {
            if (addr == "/top") {
                top_l_dist[idx][top_l_global[idx]] => d;
                if (top_l_global[idx] > 0) {
                    (active[top_l_global[idx] - 1][0] + 1) % 2 => active[top_l_global[idx] - 1][0];
                    spork ~ record(top_l_global[idx] - 1, active[top_l_global[idx] - 1][0], beat, 0, d);
                }
            }
            if (addr == "/bot") {
                bot_l_dist[idx][bot_l_global[idx]] => d;
                if (bot_l_global[idx] > 0) {
                    (active[bot_l_global[idx] - 1][1] + 1) % 2 => active[bot_l_global[idx] - 1][1];
                    spork ~ record(bot_l_global[idx] - 1, active[bot_l_global[idx] - 1][1], beat, 1, d);
                }
            }
        }
        if (side == 1) {
            if (addr == "/top") {
                top_r_dist[idx][top_r_global[idx]] => d;
                if (top_r_global[idx] > 0) {
                    (active[top_r_global[idx] - 1][0] + 1) % 2 => active[top_r_global[idx] - 1][0];
                    spork ~ record(top_r_global[idx] - 1, active[top_r_global[idx] - 1][0], beat, 0, d);
                }
            }
            if (addr == "/bot") {
                bot_r_dist[idx][bot_r_global[idx]] => d;
                if (bot_r_global[idx] > 0) {
                    (active[bot_r_global[idx] - 1][1] + 1) % 2 => active[bot_r_global[idx] - 1][1];
                    spork ~ record(bot_r_global[idx] - 1, active[bot_r_global[idx] - 1][1], beat, 1, d);
                }
            }
        }
    }

    
    private void record(int mode, int mod, dur beat, int player, int dist) {
        <<< dist >>>;
        // only records last fourth of a beat
        mic[mode][player].duration(beat);
        beat/4.0 * 3 => now;
        mic[mode][player].record(1);
        beat/4.0 => now;
        mic[mode][player].record(0);

        mic[mode][player].loopEnd(beat/4.0);
        mic[mode][player].play(1);

        while (active[mode][player] == mod) {
            mic[mode][player].rampUp(beat/8.0);
            beat/2.0 - beat/8.0 => now;
            mic[mode][player].rampDown(beat/8.0);
            beat/8.0 => now;
        }

        mic[mode][player].play(0);
    }
}
