// Proc.ck
// proc
// Eric Heep

public class Proc{

    NanoKontrol n;
   
    OscOut out;
    ("10.2.35.254", 50000) => out.dest;

    5 => int num_sections;
    4 => int num_features;
    
    // array for scaling
    float feature_avgs[num_sections][num_features];
    float feature_max[num_features];
    float feature_min[num_features];

    // sporking instrument functions
    // for (int i; i < 8; i++) {
    //     spork ~ clappers(i);
    // }
    // spork ~ spins();

    // clapper nums, ms values, and velocities
    // adjusted for the most "raucous" sound
    [0,   1,  2,  3,  4, 14, 16, 17] @=> int clap_num[];
    [32, 30, 20, 23, 24, 40, 26, 20] @=> int clap_ms[];
    [15, 15, 15,  8,  7, 15, 10, 8] @=> int clap_vel[];

    // trimpspin
    [0,  1,  2,  3,  4,  5 , 6,  7, 
     8,  9,  10, 11, 12, 13, 14, 15] @=> int spin[];

    public void features(float cen, float spr, float hfc, float crs) {
         <<< "\t",  "Cen:", cen, "\t", "Spr:", spr, "\t", "HFC:", hfc, "\t", "Crst:", crs>>>; 

    }

    public void learn(int section, float cen, float spr, float hfc, float crs) {
        if (section != -1) {
            cen => feature_avgs[section][0];
            spr => feature_avgs[section][1];
            hfc => feature_avgs[section][2];
            crs => feature_avgs[section][3];
        }
    }

    // computes stuff 
    public void calc() {

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
            if (arr[i] < val) {
                arr[i] => valn;
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
                out.add((clap_vel[idx] * vel_scl) $ int);
                out.send();
                ((128.0 - n.knob[idx]) * Math.random2f(clap_ms[idx], clap_ms[idx] + 5.0))::ms => now;
            }
            0.1::ms => now;
        }
    }

    // trimpspin cycle, not audible, but personal
    private void spins() {
        int range, off;
        while (true) {
            (n.slider[8]/127.0 * spin.cap()) $ int => range;
            for (int i; i < range; i++) {
                if (range > 0) {
                    0 => off;
                    out.start("/trimpspin");
                    out.add(60 + spin[i]);
                    out.add(30);
                    out.send();
                    5::ms => now;
                }
            }
            if (range == 0 && off == 0) {
                1 => off;
                for (int i; i < 17; i++) {
                    out.start("/trimpspin");
                    out.add(60 + spin[i]);
                    out.add(0);
                    out.send();
                }
            }
            1::ms => now;
        }
    }
}
