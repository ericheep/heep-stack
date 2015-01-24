public class HeapSort {

    public int[] heapify(int numbers[]) {
        numbers.cap() => int array_size;

        for ((array_size / 2) - 1 => int i; i >= 0; i--) {
            siftDown(numbers, i, array_size - 1) @=> numbers;
        }
        return numbers;
    }

    public int[] heapSort(int numbers[]) {
        return heapSort(numbers, 0, 0);
    }

    public int[] heapSort(int numbers[], int iteration) {
        return heapSort(numbers, iteration, 1);
    }

    public int[] heapSort(int numbers[], int iteration, int single) {
        int temp;
        numbers.cap() => int array_size;

        if (single) {
            array_size - iteration => iteration;
            numbers[0] => temp;
            numbers[iteration] => numbers[0];
            temp => numbers[iteration];
            siftDown(numbers, 0, iteration - 1) @=> numbers;
        }

        if (!single) {
            for (array_size - 1 => int i; i >= 1; i--) {
                numbers[0] => temp;
                numbers[i] => numbers[0];
                temp => numbers[i];
                siftDown(numbers, 0, i - 1) @=> numbers;
            }
        }
        return numbers;
    }
  
    private int[] siftDown(int numbers[], int root, int bottom) {
        int done, maxChild, temp;

        while ( (root*2 <= bottom) && (done != 1)) {
            if (root*2 == bottom) 
                root * 2 => maxChild;
            else if (numbers[root * 2] > numbers[root * 2 + 1]) 
                root * 2 => maxChild;
            else  
                root * 2 + 1 => maxChild;
            if (numbers[root] < numbers[maxChild]) {
                numbers[root] => temp;
                numbers[maxChild] => numbers[root];
                temp => numbers[maxChild];
                maxChild => root;
            } 
            else 
                1 => done;
        }
        return numbers;
    }
}
