// main.ck
// bring-out-your-dead
// Eric Heep

// classes
Mel mel;
FIR fir;
YourDead y;
Matrix mat;
Chromagram chr;
Visualization vis;

// sound chain
adc => FFT fft =^ RMS rms => blackhole; 
// fft parameters
second / samp => float sr;
4096 => int N => int win => fft.size;
Windowing.hamming(N) => fft.window;
UAnaBlob fft_blob;
UAnaBlob rms_blob;

// calculates transformation matrix
mel.calc(N, sr, "constantQ") @=> float mx[][];
mat.transpose(mx) @=> mx;

// cuts off unnecessary half of transformation weights
mat.cutMat(mx, 0, win/2) @=> mx;

float X[];

// main program
while (true) {
    (win/2)::samp => now;

    // creates our array of fft bins
    fft.upchuck() @=> fft_blob;

    // gets rms
    rms.upchuck() @=> rms_blob;

    // keystrength cross correlation
    mat.dot(fft_blob.fvals(), mx) @=> X;

    // wraps into an octave
    chr.wrap(X) @=> X;
    chr.quantize(X) @=> X;

    // rms scaling
    mat.rmstodb(X) @=> X;

    // fir filter
    fir.fir(X) @=> X;

    // intervallic analysis
    // decides dead response
    y.interval(X, rms_blob.fval(0));
    
    // sends filtered chroma to processing
    vis.data(X, "/data");
}
