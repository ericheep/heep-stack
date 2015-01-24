public class HeapSend {
    HeapSort hs;
    ArrayFunctions af;
    
    OscOut out;
    ("localhost", 12001) => out.dest;

    500::ms => dur global_beat;

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

        // metronome
        metroSend(metro, ref_prv.cap()/2 + ref_cur.cap()/2, beat, 0);
        
        // updates current to start with base values
        for (int i; i < array_size; i++) {
            base[i] => cur[i];
        }

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

            // metronome
            metroSend(metro, array_size, beat, i);
        }

        // outputs array for next segment
        return ref_cur;
    }

    private void metroSend(string addr, int array_size, dur beat, int side) {
       for (int i; i < array_size; i++) {
            out.start(addr);
            out.add(side % 2);
            out.add(i);
            out.send();

            // faster and faster
            if (global_beat > 350::ms) {
                global_beat - 0.10::ms => global_beat;
            }
            global_beat => now;  
        }
    }
}
