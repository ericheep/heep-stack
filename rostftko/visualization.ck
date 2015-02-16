// Visualization.ck
// Eric Heep

public class Visualization{
    // sends data to Processing for visualizations
    OscOut osc;
    osc.dest("127.0.0.1", 12001);

    fun void mag(float m, string addr) {
        osc.start(addr);
        osc.add(m);
        osc.send();
    }

    fun void which(int jpg, string addr) {
        osc.start(addr);
        osc.add(jpg);
        osc.send();
    }

    fun void phase(float ph, string addr) {
        osc.start(addr);
        osc.add(ph);
        osc.send();
    }

    fun void size(int cols, string addr) {
        osc.start(addr);
        osc.add(cols);
        osc.send();
    }

    fun void data(float x[], string addr) {
        // reducing the data down to a 256 message
        // just because processing cannot handle large
        // osc message, will have to work on later
        x.cap()/4 => int new_x;
        osc.start(addr);
        for (int i; i < new_x; i++) {
            i * 4 => int j;
            osc.add(x[j] + x[j + 1] + x[j + 2] + x[j + 3]);
        }
        osc.send();
    }
} 


