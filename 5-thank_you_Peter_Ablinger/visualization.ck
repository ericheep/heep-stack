// Visualization.ck
// Eric Heep

public class Visualization {

    OscOut osc;
    osc.dest("127.0.0.1", 12001);

    // sends RMS values of the input array to Processing
    fun void data(float x[], string addr) {
        osc.start(addr);
        for (int i; i < x.cap(); i++) {
            osc.add(x[i]);
        }
        osc.send();
    }

    // sends values of the input matrix to Processing
    fun void matrix(float x[][], string addr, dur win) {
        for (int i; i < x[0].cap(); i++) {
            osc.start(addr);
            for (int j; j < x.cap(); j++) {
                osc.add(Std.rmstodb(x[j][i]));
            }
            osc.send();
            win => now;
        }
    }
} 
