// importing OSC and NET utilities
import oscP5.*;
import netP5.*;

// custom classes, for later

// fullscreen
boolean sketchFullScreen() {
    return true;
}

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  noCursor();
  colorMode(HSB, 360);
  size(displayWidth/2, displayHeight/2);
  
  // construct classes here
  
  // OSC stuff
  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

// receiving OSC
void oscEvent(OscMessage msg) {
    // top score
    if (msg.checkAddrPattern("/onset")) {

    }
}

// main program
void loop() {
    noStroke(); 
    fill(0, 0, 0, 250);
    rect(0, 0, width, height);
}
