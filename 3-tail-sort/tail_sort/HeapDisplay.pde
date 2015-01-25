public class Display {

  // width and height variables
  float w, h;
  // quadrant variables
  float q_w, q_h;
  int g_s;

  Display(int arr_length, int grid_size) {
    w = float(width)/arr_length;
    h = float(height)/arr_length;
    q_w = float(width)/4.0;
    q_h = float(height)/4.0;
    g_s = grid_size;
  }

  void graph(int arr[]) {
    noStroke();
    for (int i = 0; i < arr.length; i++) {
      fill(0, 0, 100, 100);
      rect(w * i, height, w, h * arr[i] * -1.0);
    }
  }
}

