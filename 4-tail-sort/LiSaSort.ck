public class LiSaSort {
    ArrayFunctions a;
    4 => int modes;
    3 => int buffers;
    2 => int players;
    int buffer[modes][players];

    // two LiSa arrays, one per player, with three buffers each
    LiSa mic[buffers][modes][2];
    ADSR env[buffers][modes][2];

    Pan2 left;
    Pan2 right;

    // intializing parameters
    for (int j; j < buffers; j++) {
        for (int i; i < modes; i++) {
            adc => mic[j][i][0] => env[j][i][0] => left;
            adc => mic[j][i][1] => env[j][i][0] => right;
            mic[j][i][0].loop(1);
            mic[j][i][1].loop(1);
            mic[j][i][0].bi(1);
            mic[j][i][1].bi(1);
        }
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
            a.index(bot_r_global, modes) @=> bot_r_idx;
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


    private int[] score(int idx) {
        if (idx == 3 || idx == 4 || idx == 5) return [1, 1];
        if (idx == 6 || idx == 7 || idx == 8) return [2, 1];
        if (idx == 9 || idx == 10 || idx == 11) return [3, 1];    
        if (idx == 12 || idx == 13 || idx == 14) return [1, 2];    
        if (idx == 15 || idx == 16 || idx == 17) return [2, 2];    
        if (idx == 18 || idx == 19 || idx == 20) return [3, 2];    
        if (idx == 21 || idx == 22 || idx == 23) return [1, 3];    
        if (idx == 24 || idx == 25 || idx == 26) return [2, 3];    
        if (idx == 27 || idx == 28 || idx == 29) return [3, 3];    
        if (idx == 30 || idx == 31 || idx == 32) return [1, 4];    
        if (idx == 33 || idx == 34 || idx == 35) return [2, 4];    
        if (idx == 36 || idx == 37 || idx == 38) return [3, 4];    
        if (idx == 39 || idx == 40 || idx == 41) return [1, 5];    
        if (idx == 42 || idx == 43 || idx == 44) return [2, 5];    
        if (idx == 45 || idx == 46 || idx == 47) return [3, 5];    
        if (idx == 48 || idx == 49 || idx == 50) return [1, 6];    
        if (idx == 51 || idx == 52 || idx == 53) return [2, 6];    
        if (idx == 54 || idx == 55 || idx == 56) return [3, 6];    
        if (idx == 57 || idx == 58 || idx == 59) return [1, 7];    
        if (idx == 60 || idx == 61 || idx == 62) return [2, 7];    
        if (idx == 63 || idx == 64 || idx == 65) return [3, 7];    
        else return [0, 0];
    }

    
    private void record(int mode, int mod, dur beat, int player, int dist) {
        // a few vars
        5 * (mode + 1) => int num;
        
        // exponential vars
        dur y;
        dur echoes[num]; 

        // allowed length of playblack
        beat * (dist * 2) => dur length;

        // exp beat
        length/(num * 1.0) => dur beat_time;

        // which buffer to record into, 3 per player
        buffer[mode][player] => int idx;
        
        // buffer, mode, player
        if (buffer[mode][player] < 3) { 
            //<<< idx, "REC", "" >>>;

            // intializing LiSa to record
            mic[idx][mode][player].duration(beat * dist);
            mic[idx][mode][player].loop(1);
            mic[idx][mode][player].bi(1);
            mic[idx][mode][player].record(1);
            
            // rec time
            beat * 2.0 => now;

            mic[idx][mode][player].record(0);
        }

        score(idx)[0] => int recordings;
        score(idx)[1] => int voices;

        1.0/voices => float pos;

        if (recordings > 0 && voices > 0) {
            //<<< idx, "PLAY", "" >>>;

            for (int i; i < recordings; i++) {
                env[i][mode][player].keyOn();
                env[i][mode][player].set(10::ms, length - beat/8.0, 0.2, beat/8.0);
                for (int j; j < voices; j++) {
                    mic[i][mode][player].loopStart(j, beat);
                    mic[i][mode][player].loopEnd(j, beat * 2.0);
                    mic[i][mode][player].playPos(j, j * (beat * 2.0) * pos);
                    mic[i][mode][player].play(j, 1);
                    mic[i][mode][player].rampUp(j, beat/8.0);
                }
            }
            length  - beat/8.0 => now;
            for (int i; i < recordings; i++) {
                env[i][mode][player].keyOff();
                for (int j; j < voices; j++) {
                    mic[i][mode][player].rampDown(j, beat/8.0);
                }
            }
            beat/8.0 => now;
            for (int i; i < recordings; i++) {
                for (int j; j < voices; j++) {
                    mic[i][mode][player].play(j, 0);
                }
            }
        }

        buffer[mode][player]++;
        /*
        // builds our exponential array
        for (int i; i < num; i++) {
            Math.pow(Math.pow((1 + num),(1.0/num)), i + 1) - 1 => float beat;
            beat * beat_time => dur x;
            x - y => echoes[i];
            beat * beat_time => y;
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
        */
    }
}
