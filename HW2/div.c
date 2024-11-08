#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void divide(unsigned int dividend, unsigned int divisor) {
    unsigned int quotient = 0;
    unsigned int remainder = dividend;
    //Iterate through each bit of the dividend starting from the most significant one..
    //for this you need to shift the 32 bits to the right by 31 and then keep going
    //if divisor <= dividend
    // see how many multiples of divisor can fit into dividend
        // syntax: multiplying by 2 = left shift by i where i = 0 and is under 32
    // while tempDivisor<<1 <= dividend
        //temDivisor <<1 
        //multiple ++
    //remainder = dividend
    //if remainder is > tempDivisor then do  remainder = remainder - tempDivisor
    //
        // subtract quotient - divisor * multiple = remainder

    unsigned int tempDivisor = divisor;
    // unsigned int multiple = 0;

    while ((tempDivisor << 1) <= dividend) {
        tempDivisor <<= 1;
        // multiple++;
    }

    // for (; multiple < 32; multiple--) {
        while (tempDivisor >= divisor) {

        if (remainder >= tempDivisor){
            remainder -= tempDivisor;
            quotient = (quotient << 1) | 1;
        } else {
            quotient <<=1 ;

        }
        tempDivisor >>=1;

    }
    printf("%u / %u = %u R %u\n", dividend, divisor, quotient, remainder);
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Need exactly 3 arguments");
        return 1;
    }
    unsigned int dividend = atoi(argv[1]);
    unsigned int divisor = atoi(argv[2]);

    divide(dividend, divisor);
}