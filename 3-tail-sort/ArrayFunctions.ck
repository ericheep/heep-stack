public class ArrayFunctions {

    // checks to see if an array is sorted
    public int check(int arr[]) {
        arr.cap() => int array_size;
        int pos;

        for (int i; i < array_size - 1; i++) {
            if (arr[i] < arr[i + 1]) 
                 i => pos;
            else
                break;
        }

        if (pos == array_size - 2) {
            return 1;
        } 
        else { 
            return 0;
        }
    }

    // prints contents
    public void printArrays(int ref_prv[], int prv[], int ref_cur[], int cur[]) {
         "[" => string print;
         for (int i; i < prv.cap(); i++) {
            prv[i] + "" +=> print;
            if (i != prv.cap() - 1) {
                ", " +=> print;
            }
        }
        "] [" +=> print;
        for (int i; i < ref_prv.cap(); i++) {
            for (int j; j < ref_prv.cap(); j++) {
                if (j == prv[i]) {
                    ref_prv[j] + "" +=> print;
                }
            }
            if (i != ref_prv.cap() - 1) {
                ", " +=> print;
            }
        }
        "] || [" +=> print;
         for (int i; i < cur.cap(); i++) {
            cur[i] + "" +=> print;
            if (i != cur.cap() - 1) {
                ", " +=> print;
            }
        }
        "] [" +=> print;
        for (int i; i < ref_cur.cap(); i++) {
            for (int j; j < ref_cur.cap(); j++) {
                if (j == cur[i]) {
                    ref_cur[j] + "" +=> print;
                }
            }
            if (i != ref_cur.cap() - 1) {
                ", " +=> print;
            }
        }
        "]" +=> print;
        <<< print, "" >>>;
    }

    // shuffles array contents
    public int[] shuffle (int arr[]) {
        arr.cap() => int array_size;

        for (array_size - 1 => int i; i > 0; i--) {
            // pick a random index from 0 to i
            Math.random2(0, array_size) % (i + 1) => int j;

            // swap arr[i] with the element at random index
            arr[i] => int temp;
            arr[j] => arr[i];
            temp => arr[j];
        }
        return arr;
    }
}

