#include <iostream>
#include <fstream>

#include <stdio.h>
#include <string>
#include <vector>
#include <array>
using namespace std;
#include <algorithm> 


int getIndexInCompressed(int row, int col, int N) {
    return (row * (2 * N - row + 1)) / 2 + (col - row);
}

void triMatMult(int A[], int B[], int C[], int N) {
    for (int i = 0; i < N; i++) {
        for (int j = i; j < N ; j++){
            int sum = 0;
            for (int k = i; k <=j; k++){
                 int aIdx = getIndexInCompressed(i, k, N);
                int bIdx = getIndexInCompressed(k, j, N);
                sum += A[aIdx] * B[bIdx];
            }
            C[getIndexInCompressed(i, j, N)] = sum;
        }
    }

    
}

int main(int argc, char* argv[]) {
    ifstream fileA(argv[1]);
    ifstream fileB(argv[2]);

        // Check if the files were successfully opened
    if (!fileA.is_open() || !fileB.is_open()) {
        cerr << "Error: Unable to open input files." << endl;
        return 1;
    }

    int N;
    fileA >> N;
    fileB >> N;

    int size = (N * (N+1))/2;

    int A[size];
    int B[size];

    for (int i = 0; i < size; i++) {
        fileA >> A[i];
    }
    for (int i = 0; i < size; i++) {
        fileB >> B[i];
    }
    fileA.close();
    fileB.close();
    int C[size];

    triMatMult(A, B, C, N);

   for (int num : C) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}