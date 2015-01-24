public class Patterns {

    fun int[] patternA() {
        return [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
    }

    fun int[] patternB() {
        return [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1];
    }

    fun int[] patternC() {
        return [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1];
    }

    fun int[] patternD() {
        return [1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1];
    }

    fun int[] patternE() {
        return [1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1];
    }

    fun int[] patternA(int r) {
        patternA() @=> int arr[];
        for (int i; i < arr.cap(); i++) {
            if (arr[i] == 1) {
                arr[i] + Math.random2(0,r) => arr[i];
            }
        }
        return arr;
    }

    fun int[] patternB(int r) {
        patternB() @=> int arr[];
        for (int i; i < arr.cap(); i++) {
            if (arr[i]) {
                arr[i] + Math.random2(0,r) => arr[i];
            }
        }
        return arr;
    }

    fun int[] patternC(int r) {
        patternC() @=> int arr[];
        for (int i; i < arr.cap(); i++) {
            if (arr[i]) {
                arr[i] + Math.random2(0,r) => arr[i];
            }
        }
        return arr;
    }

    fun int[] patternD(int r) {
        patternD() @=> int arr[];
        for (int i; i < arr.cap(); i++) {
            if (arr[i]) {
                arr[i] + Math.random2(0,r) => arr[i];
            }
        }
        return arr;
    }

    fun int[] patternE(int r) {
        patternE() @=> int arr[];
        for (int i; i < arr.cap(); i++) {
            if (arr[i]) {
                arr[i] + Math.random2(0,r) => arr[i];
            }
        }
        return arr;
    }
}
