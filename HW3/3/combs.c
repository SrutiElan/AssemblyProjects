#include <stdio.h>
#include <stdlib.h>
#include "combs.h"

/*
result: p result[0][0]@8 for elements
        p *result@4
*/
void combinationUtil(int items[], int len, int k, int index, int data[], int i, int** result, int* comb_index) {
    // Base case: If the current combination is of size k, store it in the result array
    if (index == k) {
        for (int j = 0; j < k; j++) {
            result[*comb_index][j] = data[j];
        }
        (*comb_index)++;
        return;
    }

    // If no more elements are left
    if (i >= len)
        return;

    // Include current element
    data[index] = items[i];
    combinationUtil(items, len, k, index + 1, data, i + 1, result, comb_index);

    // Exclude current element
    combinationUtil(items, len, k, index, data, i + 1, result, comb_index);
}

int** get_combs(int* items, int k, int len) {
    int numCombs = num_combs(len, k);

    // Allocate memory for storing the combinations
    int** result = (int**)malloc(numCombs * sizeof(int*));
    for (int i = 0; i < numCombs; i++) {
        result[i] = (int*)malloc(k * sizeof(int));
    }

    int* currComb = (int*)malloc(k * sizeof(int));  // Array to store current combination
    int comb_index = 0;  // To track the row in result

    // Call the recursive helper function
    combinationUtil(items, len, k, 0, currComb, 0, result, &comb_index);

    free(currComb);  // Free the temporary combination array
    return result;  // Return the result array
}
