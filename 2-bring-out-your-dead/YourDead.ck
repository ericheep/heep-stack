// YourDead.ck
// bring-out-your-dead
// Eric Heep

public class YourDead {

    NanoKontrol n;
   
    OscOut out;
    ("10.2.35.254", 50000) => out.dest;

    5 => int num_sections;

    float rms_avg[num_sections];
    float cen_avg[num_sections];
    float spr_avg[num_sections];
    float hfc_avg[num_sections];
    float crs_avg[num_sections];

    spork ~ clappers();
    spork ~ snares();
    spork ~ toms();
    spork ~ bass();
    spork ~ spins();

    // clappers
    [0, 1, 2, 3, 4, 14, 16, 17] @=> int clap_arr[];

    // ganapati
    [2] @=> int gana_snare[];
    [1, 3] @=> int gana_tom[];
    [6, 7, 8] @=> int gana_bass[];

    // devibot
    [10, 11] @=> int devi_snare[];
    [0] @=> int devi_tom[];
    [6, 7, 8] @=> int devi_bass[];

    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 
     10, 11, 12, 13, 14, 15, 19] @=> int spin[];

    public void features(float rms, float cen, float spr, float hfc, float crs) {
        // <<< "RMS:", rms, "\t",  "Cen:", cen, "\t", "Spr:", spr, "\t", "HFC:", hfc, "\t", "Crst:", crs>>>; 
        /*if (n.top[8]) {
            featureActinos(rms, cen, spr, hfc, crs);
        }
        else {
            controllerActions(); 
        }
        */

    }

    public void learn(int section, float rms, float cen, float spr, float hfc, float crs) {
        if (section != -1) {
            rms => rms_avg[section];
            cen => cen_avg[section];
            spr => spr_avg[section];
            hfc => hfc_avg[section];
            crs => crs_avg[section];
        }
    }

    public void showAvgs() {
        <<< "Averages" >>>;
        for (int i; i < num_sections; i++) {
            <<< i, " RMS:", rms_avg[i], "\t",  "Cen:", cen_avg[i], "\t", "Spr:", spr_avg[i], "\t", "HFC:", hfc_avg[i], "\t", "Crst:", crs_avg[i] >>>; 
        }
    }

    // clapper cycle 
    private void clappers() {
        while (true) {
            (n.slider[0]/127.0 * 17) $ int => int vel;
            if (vel > 0) {
                out.start("/clappers");
                out.add(clap_arr[Math.random2(0, clap_arr.cap() - 1)]);
                out.add(vel);
                out.send();
                ((128.0 - n.knob[0]) * Math.random2f(5.0,8.0))::ms => now;
            }
            1::ms => now;
        }
    }

    // snare cycle
    private void snares() {
        while (true) {
            for (int i; i < devi_snare.cap(); i++) {
                (n.slider[1]/127.0 * 28) $ int => int vel;
                if (vel > 0) {
                    out.start("/devibot");
                    out.add(devi_snare[Math.random2(0, devi_snare.cap() - 1)]);
                    out.add(vel);
                    out.send();
                    ((128 - n.knob[1]) * Math.random2f(8.0,15.0))::ms => now;
                }
            }
            for (int i; i < gana_snare.cap(); i++) {
                (n.slider[1]/127.0 * 28) $ int => int vel;
                if (vel > 0) {
                    out.start("/ganapati");
                    out.add(gana_snare[Math.random2(0, gana_snare.cap() - 1)]);
                    out.add(vel);
                    out.send();
                    ((128 - n.knob[1]) * Math.random2f(8.0,15.0))::ms => now;
                }
            }
            1::ms => now;
        }
    }

    // tom cycle
    private void toms() {
        while (true) {
            for (int i; i < devi_tom.cap(); i++) {
                (n.slider[2]/127.0 * 15) $ int => int vel;
                if (vel > 0) {
                    out.start("/devibot");
                    out.add(devi_tom[i]);
                    out.add(vel);
                    out.send();
                    ((128 - n.knob[2]) * 10)::ms => now;
                }
            }
            for (int i; i < gana_tom.cap(); i++) {
                (n.slider[2]/127.0 * 15) $ int => int vel;
                if (vel > 0) {
                    out.start("/ganapati");
                    out.add(gana_tom[i]);
                    out.add(vel);
                    out.send();
                    ((128 - n.knob[2]) * 10)::ms => now;
                }
            }
            1::ms => now;
        }
    }

    // snare cycle
    private void bass() {
        while (true) {
            for (int i; i < devi_bass.cap(); i++) {
                (n.slider[3]/127.0 * 20) $ int => int vel;
                if (vel > 0) {
                    out.start("/devibot");
                    out.add(devi_bass[i]);
                    out.add(vel);
                    out.send();
                    ((128 - n.knob[3]) * 5)::ms => now;
                }
            }
            for (int i; i < gana_bass.cap(); i++) {
                (n.slider[3]/127.0 * 20) $ int => int vel;
                if (vel > 0) {
                    out.start("/ganapati");
                    out.add(gana_bass[i]);
                    out.add(vel);
                    out.send();
                    ((128 - n.knob[3]) * 5)::ms => now;
                }
            }
            1::ms => now;
        }
    }

    // snare cycle
    private void spins() {
        int range, off;
        while (true) {
            (n.slider[4]/127.0 * spin.cap()) $ int => range;
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

    // spork ~ tester();

    // 0, 1, 4-8, 10, 11
    private void tester() {
        out.start("/trimpspin");
        out.add(79);
        out.add(20);
        out.send();
    }
}
