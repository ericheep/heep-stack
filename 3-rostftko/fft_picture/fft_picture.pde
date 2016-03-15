import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

PImage[] img = new PImage[12];
String[] fname = {
  "../maroon_l.jpg", "../maroon_r.jpg",
  "../orange_l.jpg", "../orange_r.jpg", 
  "../blue_l.jpg", "../blue_r.jpg", 
  "../red_l.jpg", "../red_r.jpg"
};

float[][] l_spectra;
float[][] r_spectra;

float l_mag, r_mag, l_inc, r_inc, l_phase, r_phase, l_mv, r_mv, hght;
float l_phase_mult, r_phase_mult, l_mag_mult, r_mag_mult, l_tail, r_tail;
float inv_tail, l_tail_mult, r_tail_mult, width_div2, width_div4, height_div2;
int l_jpg, r_jpg;

int rows = 256;
int tail = 10;

boolean sketchFullScreen() {
  return true;
}


void setup() {
  noCursor();
  noStroke();
  size(displayWidth, displayHeight);
  colorMode(HSB, 360); 

  // OscProperties  properties = new OscProperties();
  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  // height of each individual rectangle
  hght = height/float(rows);

  // inverse of tail
  inv_tail = 1/float(tail);

  // placement locations
  width_div2 = width/2;
  width_div4 = width/4;
  height_div2 = height/2;

  // arrays for holding partial spectra
  l_spectra = new float[rows][tail];
  r_spectra = new float[rows][tail];

  for (int i = 0; i < fname.length; i++) {
    img[i] = loadImage(fname[i]);
    img[i].resize(width/3, 0);
  }
  imageMode(CENTER);
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/l_name") == true) {
    l_jpg = msg.get(0).intValue();
  }
  if (msg.checkAddrPattern("/r_name") == true) {
    r_jpg = msg.get(0).intValue();
  }
  if (msg.checkAddrPattern("/l_mag") == true) {
    l_mag = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/r_mag") == true) {
    r_mag = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/l_cols") == true) {
    l_inc = (width_div2)/msg.get(0).intValue();
    l_mv = 0;
  }  
  if (msg.checkAddrPattern("/r_cols") == true) {
    r_inc = (width_div2)/msg.get(0).intValue();
    r_mv = 0;
  }
  if (msg.checkAddrPattern("/l_phase") == true) {
    l_phase = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/r_phase") == true) {
    r_phase = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/l_spectra") == true) {
    for (int i = tail - 1; i != 0; i--) {
      for (int j = 0; j < rows; j++) {
        l_spectra[j][i] = l_spectra[j][i - 1];
      }
    }
    for (int i = 0; i < rows; i++) {
      l_spectra[i][0] = msg.get(i).floatValue() * 10.0 + l_phase_mult;
    }
    l_mv = l_inc + l_mv;
  }
  if (msg.checkAddrPattern("/r_spectra") == true) {
    for (int i = tail - 1; i != 0; i--) {
      for (int j = 0; j < rows; j++) {
        r_spectra[j][i] = r_spectra[j][i - 1];
      }
    }
    for (int i = 0; i < rows; i++) {
      r_spectra[i][0] = msg.get(i).floatValue() * 10.0 + r_phase_mult;
    }
    r_mv = r_inc + r_mv;
  }
}

void drawLeftSpectra() {
  l_phase_mult = l_phase * 240;
  l_tail_mult = inv_tail * 360 * l_mag;
  for (int i = 0; i < tail; i++) {
    l_tail = (tail - i) * l_tail_mult;
    for (int j = 0; j < rows; j++) {
      fill(l_spectra[j][i], 300, l_tail, l_tail);
      rect(l_mv - (3 * i), height - (j * hght), 3, hght);
    }
  }
}

void drawRightSpectra() {
  r_phase_mult = r_phase * 240;
  r_tail_mult = inv_tail * 360 * r_mag;
  for (int i = 0; i < tail; i++) {
    r_tail = (tail - i) * r_tail_mult;
    for (int j = 0; j < rows; j++) {
      fill(r_spectra[j][i], 300, r_tail, r_tail);
      rect(r_mv - (3 * i) + width_div2, height - (j * hght), 3, hght);
    }
  }
}

void opacity() {
  stroke(0, 0, 0, 0);
  fill(0, 0, 0, 7);
  rect(0, 0, width, height);
}

void draw() {
  //background(0);
  opacity();
  if (l_mv > 0) {
    image(img[l_jpg], width_div4, height_div2);
    drawLeftSpectra();
  }
  if (r_mv > 0) {
    image(img[r_jpg], width_div4 + width_div2, height_div2);
    drawRightSpectra();
  }
}

