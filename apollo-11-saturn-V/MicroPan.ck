// Micro.ck
// Eric Heep
// live sampling class centered around micro loops

public class MicroPan extends Chubgraph{
    // sound chain
    inlet => LiSa mic => MultiPan mp;

    // scoped variables
    int active, inc;
    2.0::second => dur length;
    100::ms => dur ramp;
    [-1.0, 0, 1.0] @=> float spatial_arr[];

    fun void spatialArray(float arr[]) {
        arr @=> spatial_arr;
    }

    fun void vol(float v) {
        mp.vol(v);
    }

    fun void micVol(float v) {
        mic.gain(v);
    }

    fun void rampTime(dur r) {
        r => ramp;
    }

    fun void loopTime(dur len) {
        len => length; 
    }

    fun void loop(int k) {
        if (k == 1) {
            1 => active;
            spork ~ looping();
        }
        if (k == 0) {
            0 => active; 
        }
    }

    fun void looping () {
        length => mic.duration;
        mic.record(1);
        length => now;
        mic.record(0);
        mic.play(1);
        while (active) {
            mp.pan(spatial_arr[inc]);
            (inc + 1) % spatial_arr.size() => inc; 
            mic.rampUp(ramp);
            length - ramp => now;
            mic.rampDown(ramp);
            ramp => now;
        }
        mic.play(0);
    }
}
