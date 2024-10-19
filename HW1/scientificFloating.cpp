#include <iostream>
#include <string>
using namespace std;
#include <cmath>  // for pow function
#include <algorithm> 


std::string decimalToBinary(int number) {
    std::string binary = "";
    
    // Handle the case for 0 explicitly
    if (number == 0) {
        return "0";
    }

    while (number > 0) {
        binary += (number % 2 == 0 ? "0" : "1");
        number /= 2;
    }

    // Since we construct the binary in reverse order, reverse it to get the correct binary representation
    std::reverse(binary.begin(), binary.end());
    return binary;
}
/*
convert the pre decimal point to binary
for after decimal point, subtract og number w the integer part
    mulitply it by 2, 
        if >= 1.0 then -> 1, subtract 1
        ...else 0
    keep doing it until mulitplied by 2 is = 1.0 23 times
    final decimal value: read from to bottom , so maybe use an array
add the integer part 

convert to scientific notiation
    if number is > 1 then move decimal point to left until there exists just 1.XX
        keep track of number of times = e, so exponent is 2^e
    if number is < 1 then move decimal point to right until 1.XX
        negative e 

add bias to exponent
    e + 127 = final exponent

convert biased exponent to binary 
    must be exactly 8 bits, add 0s to the front  (perhaps do + 0b00000000)?

determine mantissa
    take the 1.XXXXX scientiifc notation one, subtract 1 and cut it to just 23 bits 

final answer:
    unsigned bit + 8 exponent bits + 23 mantissa bits
*/



void floatToBinary(float f){
    int integerPart = (int)f;

    string integerBinary = decimalToBinary(integerPart) + ".";


    float decimal = f-integerPart;
    string binary = "";
    int i = 0;
    while ((decimal != 0) &&( i < 23)){
        decimal = decimal*2;
        if (decimal >=1.0){
            binary+="1";
            decimal = decimal - 1.0;
        }
        else {
            binary +="0";
        }
        i++;
    }
    cout<<"\n final = " << integerBinary <<binary;

};

// convert to scientific notiation
//     if number is > 1 then move decimal point to left until there exists just 1.XX
//         keep track of number of times = e, so exponent is 2^e
//     if number is < 1 then move decimal point to right until 1.XX
//         negative e 

string toBinaryString(int value, int bits){
    string binary = "";

    // 101001010 bits = 9.. start at 
    for (int i = bits-1; i >=0 ; i--){
        char temp = (value>>i) & 1;
        binary += temp ? '1' : '0';
    }
    return binary;

}
string binaryToSci(float f) {
    unsigned int floatInt = *((unsigned int*)&f);
    unsigned int sign = (floatInt >> 31) & 1;
    unsigned int exponent = (floatInt >> 23) & 0b11111111;
    unsigned int mantissa = floatInt & 0x7FFFFF;

    int unBiasedExponent = exponent-127;
    
    string binary = (sign == 1 ? "-" : "");
    binary = "1." + toBinaryString(mantissa, 23) + "E" + to_string(unBiasedExponent);

    return binary;
    

}

int main(int argc, char* argv[]) {
    float f;
    cout<<"Please enter a float: ";
    cin>> f;
    
    // floatToBinary(f);
    cout<<binaryToSci(f);


    // //casting the float to int
    // unsigned int float_int = *((unsigned int*)&f);
    // cout<<"\nfloat int is"<<float_int;

}