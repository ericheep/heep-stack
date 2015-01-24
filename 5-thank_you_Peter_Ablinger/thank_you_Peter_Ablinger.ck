// thank_you_Peter_Ablinger.ck
// Eric Heep

// classes
Mel mel;
SinTest s;
Matrix mat;
Chromagram c;
Visualization vis;

// sound chain
adc => FFT fft => blackhole;

// fft parameters 
second / samp => float sr;
2048 => int N => fft.size;
(N)::samp => dur hop;
Windowing.hamming(N) => fft.window;

UAnaBlob blob;

// constant Q transformation matrix
mel.calc(N, sr, "constantQ") @=> float mx[][];
mat.transpose(mx) @=> mx;

// cuts the transformation matrix
mat.cutMat(mx, 0, N/2) @=> mx;

// main program
while (true) {
    hop => now;

    // creates our array of fft bins
    fft.upchuck() @=> blob;
    
    // transforms fft into 264 constantQ bins
    mat.dot(blob.fvals(), mx) @=> float X[];

    // wraps every three adjacent notes into 88
    c.constantQ(X) @=> X;
    //c.wrap(X) @=> X;

    // rms scaling
    //mat.rmstodb(X) @=> X;

    // sends 88 bin values to Processing
    // vis.data(X, "/data");

    // 
    mat.cut(X, 55, 88) @=> X;
    s.listen(X, hop);
}
