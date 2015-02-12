// main.ck
// proc
// Eric Heep

// classes
Mel mel;
FIR fir;
Proc proc;
Matrix mat;
Spectral spc;

// keyboard stuff
Hid key;
HidMsg msg;
0 => int device;
if (me.args())me.arg(0) => Std.atoi => device;

// if no keyboard is present, the program will exit
if (!key.openKeyboard(device))me.exit();
<<< "Keyboard '" + key.name() + "' is activated!","">>>;

// sound chain
adc => FFT fft =^ RMS rms_ugen => blackhole; 
// fft parameters
second / samp => float sr;
2048 => int N => int win => fft.size;
Windowing.hamming(N) => fft.window;
UAnaBlob fft_blob;
UAnaBlob rms_blob;

// main fft
float X[];

// var
float cen, spr, crst, rms, hfc;

// learning variable
int learn, section;
1 => learn;
// for training min and max
fun void input() {
    while (true) {
        key => now;
        while (key.recv(msg)) {
            if (msg.isButtonDown()) {
                1 => learn;
                if (msg.ascii == 49) {
                    0 => section;
                }
                if (msg.ascii == 50) {
                    1 => section;
                }
                if (msg.ascii == 51) {
                    2 => section;
                }
                if (msg.ascii == 52) {
                    3 => section;
                }
                if (msg.ascii == 53) {
                    4 => section;
                }
                if (msg.ascii == 96) {
                    -1 => section;
                    proc.calc();
                    0 => learn;
                }
            }
        }
    }
}

spork ~ input();

// main program
while (true) {
    // creates our array of fft bins
    fft.upchuck() @=> fft_blob;

    // gets rms
    rms_ugen.upchuck() @=> rms_blob;

    // low level spectral features 
    spc.centroid(fft_blob.fvals(), sr, N) => cen;
    spc.spread(fft_blob.fvals(), sr, N) => spr;
    spc.crest(fft_blob.fvals()) => crst; 
    spc.hfc(fft_blob.fvals()) => hfc;

    if (rms_blob.fval(0) > 0.0001) {
        fir.fir(cen, "cen") => cen;
        fir.fir(spr, "spr") => spr;
        fir.fir(hfc, "hfc") => hfc;
        fir.fir(crst, "crst") => crst;

        if (learn) {
            proc.learn(section, [cen, hfc]);
        }
        else {
            proc.features([cen, hfc]);
        }
    }

    // hop size of 50%
    (win/2)::samp => now;
}
