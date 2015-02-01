// YourDead.ck
// bring-out-your-dead
// Eric Heep

public class YourDead {
   
    // for the argMax function
    Matrix mat;

    int dyad[2];

    // main function that returns an interval
    public void interval(float ch[], float rms) {

        // returns two highest indices
        mat.argMax(ch, 2) @=> dyad; 
        
        if (rms > 0.002) {
            <<< Math.abs(dyad[0] - dyad[1]) >>>;
        }
    }
}


