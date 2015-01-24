public class Grid {

  // player
  int p;
  // x-origin, y-origin
  float x, y;
  // grid block size, diameter of ellipse  
  float s, d, m, ex_mod, pls;

  // constructor, sets size and origin points of grid quadrants 
  Grid (int player, float size, float diameter, float metro_size, int max) {
    p = player;
    s = size;
    d = diameter;
    m = metro_size;

    // sets origin point of each player
    if (p == 0) {
      y = float(height)/4.0;
      x = float(width)/4.0;
    }
    if (p == 1) {
      y = float(height)/4.0;
      x = float(width)/4.0 * 3;
    }
    if (p == 2) {
      y = float(height)/4.0 * 2;
      x = float(width)/4.0;
    }
    if (p == 3) {
      y = float(height)/4.0 * 2;
      x = float(width)/4.0 * 3;
    }
  }

  // draws grid and dots according to the array
  public void score(int rows, int cols, int arr[], int ref[], int r, int side, float ex) {
    float y_offset = (rows - 1) * 0.5 * s;

    // sets beginning and ending x locations according to the number of columns
    float row_x1 = x - (cols - 1.0) * 0.5 * s;
    float row_x2 = x + (cols - 1.0) * 0.5 * s;

    float col_y1 = y - y_offset;
    float col_y2 = (rows - 1) * s + y - y_offset;

    if (cols > 0) {
      // draws horizontal lines according to row numbers
      for (int i = 0; i < rows; i++) {
        line(row_x1, i * s + y - y_offset, row_x2, i * s + y - y_offset);
      }

      // draw vertical lines according to column numbers
      for (int i = 0; i < cols; i++) {
        if (i % 2 == 0) {
          if (r == i) {
            pls = 10;
            ex_mod = ex * 2;
          } else {
            pls = 0;
            ex_mod = ex;
          }
        } else {
          pls = 0;
          ex_mod = 0;
        }
        if (rows == 1) {
          line(row_x1 + (i * s), y - (0.25 * s) - ex_mod - pls, row_x1 + (i * s), 0.25 * s + y + ex_mod + pls);
        } else {
          line(row_x1 + (i * s), col_y1 - ex_mod - pls, row_x1 + (i * s), col_y2 + ex_mod + pls);
        }
      }
    }

    dots(row_x1, col_y1, rows, cols, arr, ref, r);
    //metro(row_x1, col_y2, r, cols, side);
  }

  // draws dots over the grid according to the sorting array and the which array
  private void dots(float r_x1, float c_y1, int rows, int cols, int arr[], int ref[], int r) {
    int check = 0;
    for (int i = 0; i < cols; i++) {
      check = ref[arr[i]];
      for (int j = 0; j < rows; j++) {
        if (j == check - 1) {
          ellipse(r_x1 + (i * s), c_y1 + (s * j), d, d);
        }
      }
    }
  }

  // metronome
  private void metro(float r_x1, float c_y2, int r, int cols, int side) {
    if (p % 2 == side) {
      if (r % 2 == 0) {
        ellipse(r_x1 + (r * s), c_y2 + s, m, m);
      }
    }
  }
}

