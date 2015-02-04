// main.ck
// bring-out-your-dead
// Eric Heep

// classes
Mel mel;
FIR fir;
YourDead y;
Matrix mat;
Spectral spc;
// Chromagram chr;
Visualization vis;

// sound chain
adc => FFT fft =^ RMS rms => blackhole; 
// fft parameters
second / samp => float sr;
1024 => int N => int win => fft.size;
Windowing.hamming(N) => fft.window;
UAnaBlob fft_blob;
UAnaBlob rms_blob;

// calculates transformation matrix
// mel.calc(N, sr, "constantQ") @=> float mx[][];
// mat.transpose(mx) @=> mx;

// cuts off unnecessary half of transformation weights
// mat.cutMat(mx, 0, win/2) @=> mx;

// main fft
float X[];

// var
float cen, spr, crst;

// main program
while (true) {
    // creates our array of fft bins
    fft.upchuck() @=> fft_blob;

    // gets rms
    rms.upchuck() @=> rms_blob;

    // low level spectral features 
    spc.centroid(fft_blob.fvals(), sr, N) => cen;
    spc.spread(fft_blob.fvals(), sr, N) => spr;
    spc.crest(fft_blob.fvals()) => crst; 

    // chroma cross correlation
    // mat.dot(fft_blob.fvals(), mx) @=> X;

    // wraps into an octave
    // chr.wrap(X) @=> X;
    // chr.quantize(X) @=> X;

    // rms scaling
    // mat.rmstodb(X) @=> X;

    // fir filter
    // fir.matFir(X) @=> X;
    if (rms_blob.fval(0) > 0.0001) {
        fir.fir(cen, "cen") => cen;
        fir.fir(spr, "spr") => spr;
        fir.fir(crst, "crst") => crst;
    }

    // dead response
    y.features(rms_blob.fval(0), cen, spr, crst);
    
    // sends filtered chroma to Processing
    vis.data([rms_blob.fval(0), cen, spr, crst], "/data");

    // hop size of 50%
    (win/2)::samp => now;
}
