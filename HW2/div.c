#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/**
 * sources: chatgpt for errors and debugging
 * https://www.exploringbinary.com/binary-division/
 */
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

    /**find the largest multiple of divisor that can go into the dividend. 
    for large dividends, tempDivisor might keep shifting to the left so much 
    that it overflows 32 bits.
    (tempDivisor << 1) > tempDivisor checks to make sure that if that sort of wrapping happens
    to exit  **/
    while (((tempDivisor << 1) > tempDivisor) && (tempDivisor << 1) <= dividend) {
        tempDivisor <<= 1;

    }

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
    unsigned int dividend = (unsigned int)strtoul(argv[1], NULL, 10);
    unsigned int divisor = (unsigned int)strtoul(argv[2], NULL, 10);

    divide(dividend, divisor);
}