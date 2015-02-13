public class ReadImage extends Chubgraph {
    IFFT ifft => BlackmanHarrisEnv env => outlet;
    BlackmanHarris bh;
    Visualization v;

    FileIO file;
    int active, bins, frames, count, offst, end, stop;
    float phse, rte, prev_rte, mag;
    "/data" => string addr;
    "/phase" => string phAddr;
    "/mag" => string magAddr;

    2 * pi => float tau;

    float m[0];
    float ph[0];
    float frq[0];
    float w[0];
    float w_o[0];
    float send[0];
    complex X[0];
    
    // for pausing
    Event e;

    // OSC address
    fun void address(string a) {
        a => addr; 
    }

    // initializes and loads in file
    fun void load(string fname, string which, int jpg) {
        file.open(fname, FileIO.READ);
        file => string init;
        file => bins;
        file => frames;

        <<< fname, "(", bins, ",", frames, ")" >>>;

        if (which == "/left") {
            "/l_mag" => magAddr;
            "/l_phase" => phAddr;
            v.which(jpg, "/l_name");
            v.size(frames, "/l_cols");
            address("/l_spectra");
        }
        if (which == "/right") {
            "/r_mag" => magAddr;
            "/r_phase" => phAddr;
            v.which(jpg, "/r_name");
            v.size(frames, "/r_cols");
            address("/r_spectra");
        }

        bins => X.size; 
        bins => m.size;
        bins => ph.size;
        bins => w.size;
        bins => w_o.size;
        bins => send.size;

        bh.calc(bins) @=> w; 
        bh.calc(bins) @=> w_o;

        bins => frq.size;

        for (int i; i < bins; i++) {
            i * (second/samp)/bins/2.0 => frq[i];
        }
        play(1);
    }

    // modifies the magnitudes of the bins
    fun void magnitude(float m) {
        v.mag(m, magAddr);
        m * 2.0 => m;
        for (int i; i < bins; i++) {
            if (m >= 1.0) {
                m/2.0 + w[i] => w_o[i];    
                if (w_o[i] > 1.0) {
                    1.0 => w_o[i];
                }
            }
            if (m < 1.0) {
                w[i] * m/2.0 => w_o[i];
            }
        }
    }

    // sets the phase scaling of the complex spectrum
    fun void phase(float p) {
        v.phase(p, phAddr);
        p => phse;
    }

    // sets the rate of playback
    fun void rate(float r) {
        r => rte;
    }

    // turns on and off playing
    fun void play(int p) {
        if (p) {
            1 => active; 
            spork ~ playing();
        }
        else {
            0 => active;
        }
    }

    fun void pause(int p) {
        p => stop;
        if (p == 0) {
            e.broadcast();
        }
    }

    // controls the position of the window
    fun void windowOffset(float p) {
        float temp[bins];
        (p * bins) $ int => int pos;    
        for (int i; i < w.cap(); i++) {
            w_o[(i + pos) % bins] => temp[i];  
        }
        for (int i; i < w.cap(); i++) {
            temp[i] => w_o[i]; 
        }
    }

    fun void playing() {
        while (active == 1 && count < frames) {
            
            // ensures there is data to be read
            count++;

            // loop for creating a window
            for (int i; i < bins; i++) {
                // phase scaling
                (frq[i] + ph[i]) % 1.0 => ph[i];

                // loading magnitudes
                file => m[i];

                // complex spectrum and artificial phase
                #(m[i], ph[i] * tau * phse) => X[i];
                
                m[i] * w_o[i] => send[i];
                // magnitude scaling
                X[i] * w_o[i] => X[i];
            }
            // inverse fft that reads the window
            ifft.transform(X);
            v.data(send, addr);

            if (rte != prev_rte) {
                env.calc((rte * bins/2)::samp);
            }
    
            // speed at which it plays back
            env.rampUp();
            ((bins * rte)/2)::samp => now;
            env.rampDown();
            ((bins * rte)/2)::samp => now;

            if (stop == 1) {
               e => now;
            }
        }
        1 => end;
    }
}
