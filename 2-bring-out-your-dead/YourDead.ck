// YourDead.ck
// bring-out-your-dead
// Eric Heep

public class YourDead {
   
    // for the argMax function
    Matrix mat;

    int dyad[1];

    // uses filtered data to decide response 
    public void features(float ch[], float rms, float cen,  float spr, float crst) {

        // returns two highest indices
        mat.argMax(ch, 1) @=> dyad; 
        <<< cen, spr, crst >>>; 

        if (rms > 0.0001) {
            //<<< dyad[0] >>>;
            //<<< Math.abs(dyad[0] - dyad[1]) >>>;
        }
    }
}


