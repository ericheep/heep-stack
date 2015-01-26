public class LiSaSort {
    ArrayFunctions a;
    5 => int modes;

    // two LiSa arrays, one per player
    LiSa mic[modes][2];

    Pan2 left;
    Pan2 right;

    // intializing parameters
    for (int i; i < modes; i++) {
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
    int top_l_idx[0][modes];
    int top_r_idx[0][modes];
    int bot_l_idx[0][modes];
    int bot_r_idx[0][modes];

    // distance arrays
    int top_l_dist[0][modes];
    int top_r_dist[0][modes];
    int bot_l_dist[0][modes];
    int bot_r_dist[0][modes];

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
        // a few vars
        5 * (mode + 1) => int num;
        
        // exponential vars
        dur y;
        dur echoes[num]; 
        beat * (dist * 2) => dur length;
        length/(num * 1.0) => dur beatTime;
        
        // intializing LiSa to record
        mic[mode][player].duration(beat * dist);

        // builds our exponential array
        for (int i; i < num; i++) {
            Math.pow(Math.pow((1 + num),(1.0/num)), i + 1) - 1 => float beat;
            beat * beatTime => dur x;
            x - y => echoes[i];
            beat * beatTime => y;
        }

        // exponential decay
        if (mode == 0 || mode == 1 || mode == 2) {
            echoes[num - 1]/3.0 => now;
            mic[mode][player].record(1); 
            echoes[num - 1]/3.0 * 2.0 => now;
            mic[mode][player].record(0);
            mic[mode][player].play(1);
            for (num - 2 => int i; i >= 0; i--) {
                mic[mode][player].playPos(0::samp);
                mic[mode][player].rampUp(echoes[i]/6.0);
                echoes[i] - echoes[i]/6.0 => now;
                mic[mode][player].rampDown(echoes[i]/6.0);
                echoes[i]/6.0 => now;
            }
            mic[mode][player].play(0);
        }

        if (mode == 1) {
        }

        if (mode == 2) {
        }

        if (mode == 3) {
        }

        mic[mode][player].play(0);
    }
}
