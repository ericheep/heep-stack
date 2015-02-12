// Proc.ck
// proc
// Eric Heep

public class Proc{

    NanoKontrol n;
   
    OscOut out;
    ("10.2.35.254", 50000) => out.dest;

    3 => int num_sections;
    2 => int num_features;
  
    int calculated;

    // array for scaling
    float feature_avgs[num_sections][num_features];
    float feature_max[num_features];
    float feature_min[num_features];
    float feature_scl[num_features];
    float feature_ctrl[num_features];

    // sporking instrument functions
    for (int i; i < 8; i++) {
       spork ~ clappers(i);
    }
    // spork ~ spins();

    // clapper nums, ms values, and velocities
    // adjusted for the most "raucous" sound
    [ 0,  1,  2,  3,  4, 14, 16, 17] @=> int clap_num[];
    [32, 30, 20, 23, 24, 40, 26, 20] @=> int clap_ms[];
    [15, 15, 15,  8,  7, 15, 10,  8] @=> int clap_vel[];

    [ 0,  1,  0,  1,  0,  1,  0,  1] @=> int fv[];
    [ 1,  0,  1,  0,  1,  0,  1,  0] @=> int fr[];

    // trimpspin
    [0,  1,  2,   3,  4,  5,  6,  7, 
     8,  9,  10, 11, 12, 13, 14, 15] @=> int spin[];

    public void features(float arr[]) {
        for (int i; i < arr.cap(); i++) {
            (arr[i] - feature_min[i])/feature_scl[i] => feature_ctrl[i];
            if (feature_ctrl[i] > 1.0) {
                1.0 => feature_ctrl[i];  
            }
            if (feature_ctrl[i] < 0) {
                0.0 => feature_ctrl[i];
            }
        }
        string print;
        for (int i; i < arr.cap(); i++) {
            feature_ctrl[i] + " " +=> print; 
        }
        <<< print, "" >>>;
    }

    public void learn(int section, float arr[]) {
        if (section != -1) {
            for (int i; i < arr.cap(); i++) {
                arr[i] => feature_avgs[section][i];
            }
        }
    }

    // computes stuff 
    public void calc() {
        float arr[0]; 
        for (int i; i < num_features; i++) {
            for (int j; j < num_sections; j++) {
                arr << feature_avgs[j][i];
            }
            max(arr) => feature_max[i];
            min(arr) => feature_min[i];

            arr.clear();
        }
        <<< "Features ----- ", "" >>>;
        for (int i; i < num_sections; i++) {
            <<< feature_avgs[i][0], feature_avgs[i][1] >>>; //, feature_avgs[i][2], feature_avgs[i][3] >>>;
        }
        <<< "Max ----------- ", "" >>>;
        <<< feature_max[0],feature_max[1] >>>; //, feature_max[2], feature_max[3] >>>;
        <<< "Min -----------", "" >>>;
        <<< feature_min[0],feature_min[1] >>>; //, feature_min[2], feature_min[3] >>>;

        for (int i; i < num_features; i++) {
            feature_max[i] - feature_min[i] => feature_scl[i]; 
        }
        1 => calculated;
    }

    // finds the min of an array
    private float min(float arr[]) { 
        arr[0] => float val;
        for (1 => int i; i < arr.cap(); i++) {
            if (arr[i] < val) {
                arr[i] => val;
            }
        }
        return val;
    }

    // finds the max of an array
    private float max(float arr[]) { 
        float val;
        for (int i; i < arr.cap(); i++) {
            if (arr[i] > val) {
                arr[i] => val;
            }
        }
        return val;
    }

    // clapper cycle 
    private void clappers(int idx) {
        while (true) {
            n.slider[idx]/127.0 => float vel_scl;
            if (vel_scl > 0) {
                out.start("/clappers");
                out.add(clap_num[idx]);
                if (n.slider[8]/127.0 > Math.random2f(0.0, 1.0)) { 
                    out.add((clap_vel[idx] * vel_scl * feature_ctrl[fv[idx]]) $ int);
                }
                else {
                    out.add((clap_vel[idx] * vel_scl) $ int);
                }
                out.send();
                if (n.slider[8]/127.0 > Math.random2f(0.0, 1.0)) { 
                    ((128.0 - n.knob[idx]) * feature_ctrl[fr[idx]] * Math.random2f(clap_ms[idx], clap_ms[idx] + 5.0))::ms => now;
                }
                else {
                    ((128.0 - n.knob[idx]) * Math.random2f(clap_ms[idx], clap_ms[idx] + 5.0))::ms => now;
                }
            }
            0.1::ms => now;
        }
    }

    // trimpspin cycle, not audible, but personal
    private void spins() {
        int range, off;
        while (true) {
            (n.slider[8]/127.0 * spin.cap()) $ int - 1 => range;
            for (int i; i < range; i++) {
                if (range > 0) {
                    0 => off;
                    out.start("/trimpbeat");
                    out.add(60 + spin[i]);
                    out.add(30);
                    out.send();
                    5::ms => now;
                }
            }
            if (range == 0 && off == 0) {
                1 => off;
                for (int i; i < 16; i++) {
                    out.start("/trimpbeat");
                    out.add(60 + spin[i]);
                    out.add(0);
                    out.send();
                }
            }
            1::ms => now;
        }
    }
}
