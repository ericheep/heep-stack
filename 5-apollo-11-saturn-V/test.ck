SndBuf apollo => dac;
apollo.read(me.dir() + "apollo11saturnVaudio.wav");
apollo.rate(0.1);

while (true) {
    1::ms => now;
}
