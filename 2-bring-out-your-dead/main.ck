// 1-floor.ck
// Eric Heep

// classes
Mel mel;
Matrix mat;
Chromagram chr;

// sound chain
adc => FFT fft => blackhole;

// fft parameters 
second / samp => float sr;
4096 => int N => int win => fft.size;
Windowing.hamming(N) => fft.window;
UAnaBlob blob;

// calculates transformation matrix
mel.calc(N, sr, "constantQ") @=> float mx[][];
mat.transpose(mx) @=> mx;

// cuts off unnecessary half of transformation weights
mat.cutMat(mx, 0, win/2) @=> mx;

float X[];

// main program
while (true) {
    win::samp => now;

    // creates our array of fft bins
    fft.upchuck() @=> blob;

    // keystrength cross correlation
    mat.dot(blob.fvals(), mx) @=> X;

    // wraps into an octave
    chr.wrap(X) @=> X;

    // rms scaling
    mat.rmstodb(blob.fvals()) @=> X;

    <<< X[0], "\t", X[1], "\t", X[2], "\t", X[3], "\t", X[4], "\t", X[5], "\t", X[6],"\t", X[7],"\t", X[8],"\t", X[9],"\t", X[10],"\t", X[11] >>>;
}
