public class HeapSend {
    HeapSort hs;
    LiSaSort ls;
    ArrayFunctions af;
    
    OscOut out;
    ("localhost", 12001) => out.dest;

    // sends array to Processing
    private void arraySend(string addr, int ref[], int arr[]) {
        arr.cap() => int array_size;
        out.start(addr);
        out.add(array_size);
        for (int i; i < array_size; i++) {
            out.add(ref[i]);
        }
        for (int i; i < array_size; i++) {
            out.add(arr[i]);
        }
        out.send();
    }

    // sorts one instance at a time
    public int[] arraySort(string addr, dur beat, int ref_prv[], int ref_cur[]){
        ref_cur.cap() => int array_size;
        // for metronome
        addr + "Metro" => string metro;

        // builds array
        int base[array_size];
        int cur[array_size];
        int prv[array_size];
        
        //  populates pre_ordered array with ordered values
        int prv_ordered[ref_prv.cap()];
        for (int i; i < ref_prv.cap(); i++) {
            i => prv_ordered[i];
        }

        // populates base array with ordered values
        for (int i; i < array_size; i++) {
            i => base[i];
        } 

        // shuffles array
        af.shuffle(base) @=> base;

        // initial sorting
        hs.heapify(base) @=> base;

        // prints
        // af.printArrays(ref_prv, prv_ordered, ref_cur, base);

        // send to Processing
        arraySend(addr + "L", prv_ordered, ref_prv);
        arraySend(addr + "R", base, ref_cur);

        // updates current to start with base values
        for (int i; i < array_size; i++) {
            base[i] => cur[i];
        }

        // LiSa prime function, before every metro
        ls.prime(addr, prv_ordered, base, ref_prv, ref_cur);

        // metronome
        metroSend(addr, ref_prv, ref_cur, beat, 0);
        
        // sorting logic
        for (1 => int i; i < array_size; i++) {
            hs.heapSort(base, i) @=> base;

            if (i % 2 == 0) {
                for (int k; k < array_size; k++) {
                    base[k] => cur[k];
                }
            }
            if (i % 2 == 1) {
                for (int k; k < array_size; k++) {
                    base[k] => prv[k];
                }
            }
            // print
            // af.printArrays(ref_cur, prv, ref_cur, cur);

            // send to Processing
            arraySend(addr + "L", prv, ref_cur);
            arraySend(addr + "R", cur, ref_cur);
     
            // LiSa prime function, before every metro
            ls.prime(addr, prv, cur, ref_cur, ref_cur);

            // metronome
            metroSend(addr, prv, cur, beat, i % 2);
        }

        // outputs array for next segment
        return ref_cur;
    }

    // sends out 16th notes
    private void metroSend(string addr, int left_arr[], int right_arr[], dur beat, int side) {
        int array_size;
        if (side == 0) {
            left_arr.cap() => array_size;
        }
        else if (side == 1) {
            right_arr.cap() => array_size;
        }

        for (int i; i < array_size * 2; i++) {
            out.start(addr + "Metro");
            out.add(side);
            out.add(i);
            out.send();
            if (i % 2 == 0) {
                ls.eval(addr, i/2, beat, side);
            }
            beat => now;  
        }
    }
}
