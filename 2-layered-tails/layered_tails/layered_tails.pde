// importing OSC and NET utilities
import oscP5.*;
import netP5.*;

// custom classes
Grid[] g;
Display d;

int max = 24;

int c, b_color, d_color, b_sat, d_bright, b_bright, inc;

// top params
float t_ex_l, t_ex_r;
int t_beat, t_max_l, t_max_r;
int t_size_l, t_size_r, t_side;
int[] t_l = new int[max];
int[] t_r = new int[max];
int[] t_ref_l = new int[max];
int[] t_ref_r = new int[max];

// vibe params
float b_ex_l, b_ex_r;
int b_beat, b_max_l, b_max_r;
int b_size_l, b_size_r, b_side;
int[] b_l = new int[max];
int[] b_r = new int[max];
int[] b_ref_l = new int[max];
int[] b_ref_r = new int[max];

// grid params
float grid_size, dot_size, metro_size;

// sets fullscreen

boolean sketchFullScreen() {
  return true;
}



// setting OSC
OscP5 oscP5;
NetAddress myRemoteLocation;

// sets up classes and initializes array values
void setup() {
  noCursor();
  ellipseMode(CENTER);
  strokeCap(PROJECT);
  colorMode(HSB, 360);
  size(displayWidth, displayHeight);

  grid_size = width/27.25;
  dot_size = width/33.0;
  metro_size = width/400.0;

  // grid
  g = new Grid[4];
  for (int i = 0; i < 4; i++) {
    g[i] = new Grid(i, grid_size, dot_size, metro_size, max);
  }

  // initializing background display
  //d = new Display(, grid_size);

  // OSC address
  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void oscEvent(OscMessage msg) {
  // top score
  if (msg.checkAddrPattern("/topL")) {
    t_size_l = msg.get(0).intValue();
    for (int i = 0; i < t_size_l; i++) {
      t_l[i] = msg.get(i + 1).intValue();
    }

    t_max_l = 0;
    for (int i = 0; i < t_size_l; i++) {
      t_ref_l[i] = msg.get(i + 1 + t_size_l).intValue(); 
      if (t_ref_l[i] > t_max_l) {
        t_max_l = t_ref_l[i];
      }
    }
  }
  // rightside
  if (msg.checkAddrPattern("/topR")) {
    t_size_r = msg.get(0).intValue();
    for (int i = 0; i < t_size_r; i++) {
      t_r[i] = msg.get(i + 1).intValue();
    }
    t_max_r = 0;
    for (int i = 0; i < t_size_r; i++) {
      t_ref_r[i] = msg.get(i + 1 + t_size_r).intValue();
      if (t_ref_r[i] > t_max_r) {
        t_max_r = t_ref_r[i];
      }
    }
  }

  // leftside
  if (msg.checkAddrPattern("/botL")) {
    b_size_l = msg.get(0).intValue();
    for (int i = 0; i < b_size_l; i++) {
      b_l[i] = msg.get(i + 1).intValue();
    }

    b_max_l = 0;
    for (int i = 0; i < b_size_l; i++) {
      b_ref_l[i] = msg.get(i + 1 + b_size_l).intValue(); 
      if (b_ref_l[i] > b_max_l) {
        b_max_l = b_ref_l[i];
      }
    }
  }
  // rightside
  if (msg.checkAddrPattern("/botR")) {
    b_size_r = msg.get(0).intValue();
    for (int i = 0; i < b_size_r; i++) {
      b_r[i] = msg.get(i + 1).intValue();
    }
    b_max_r = 0;
    for (int i = 0; i < b_size_r; i++) {
      b_ref_r[i] = msg.get(i + 1 + b_size_r).intValue();
      if (b_ref_r[i] > b_max_r) {
        b_max_r = b_ref_r[i];
      }
    }
  }

  if (msg.checkAddrPattern("/topMetro")) {
    t_side = msg.get(0).intValue();
    t_beat = msg.get(1).intValue();
    if (t_side == 1 && t_beat == 0) {
      t_ex_l = 0;
    } else if (t_beat == 0) {
      t_ex_r = 0;
    }
  }

  if (msg.checkAddrPattern("/botMetro")) {
    b_side = msg.get(0).intValue();
    b_beat = msg.get(1).intValue();
    if (b_side == 1 && b_beat == 0) {
      b_ex_l = 0;
    } else if (b_beat == 0) {
      b_ex_r = 0;
    }
  }
}

void exAdd(float add) {
  t_ex_l += add;
  t_ex_r += add;   
  b_ex_l += add;
  b_ex_r += add;
}

// main loop
void draw() {
  noStroke();
  fill(0, 0, 0, 250);
  rect(0, 0, width, height);
  exAdd(0.2);
  strokeWeight(3);
  stroke(0, 360, 360);
  g[0].score(t_max_l, t_size_l, t_l, t_ref_l, t_beat, t_side, t_ex_l);
  g[1].score(t_max_r, t_size_r, t_r, t_ref_r, t_beat, t_side, t_ex_r);
  g[2].score(b_max_l, b_size_l, b_l, b_ref_l, b_beat, b_side, b_ex_l);
  g[3].score(b_max_r, b_size_r, b_r, b_ref_r, b_beat, b_side, b_ex_r);
}

