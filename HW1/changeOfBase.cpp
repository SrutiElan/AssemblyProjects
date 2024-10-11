#include <iostream>
#include <string>
#include <cctype>
#include <cmath>  // for pow function
#include <vector>  // for std::vector


std::string changeOfBase(int oldBase, int newBase, std::string oldNumber ){
    //base 10: sum = oldNumber digit i * oldBase^i 
    //quotient = sum/newBase
    //remainders[i] = quotient - quotient(as an int??)
    //keep going until quotient(as an int) = 0
    //return remainders[i=size-1 -> i = 0] as digits
    int sumBase10 = 0;
    int digit;
    for (int i = 0; i< oldNumber.length(); i++){
        if (isalpha(oldNumber[i])){
            digit = toupper(oldNumber[i]) - 'A' + 10;
        }
        else if (isdigit(oldNumber[i])){
            digit=oldNumber[i];
        }
        sumBase10 = digit* pow(oldBase,i);
    }
    float quotient;
    std::vector<int> remainders;
    while (int(quotient) != 0){
        quotient = sumBase10/newBase;
        remainders.push_back(quotient-int(quotient));
    }
    std::string newNumber = "\0";
    
    for (std::vector<int>::iterator it = remainders.begin(); it!=remainders.end(); it++){
        // For values between 0 and 9, append '0' + remainder. 
        //For values between 10 and 35, append 'A' + (remainder - 10).
        if (*it > 0 || *it < 9){
            newNumber+=('0'+ *it);
        }
        else {
            newNumber += (*it - 10 + 'A');
        }
    }

    return newNumber;
}

int main(int argc, char* argv[]) {
    int oldBase;
    int newBase;
    std::string oldNumber;
    std::string newNumber;

    std::cout<<"Please enter the number's base: ";
    std::cin >> oldBase;
    if (oldBase < 2 || oldBase > 36){
        std::cout<<"invalid base";
        return 1;
    }

    std::cout<<"Please enter the number: ";
    std::cin >> oldNumber;
    // if (oldNumber < 2 || oldNumber > 36){
    //     std::cout<<"invalid number";
    //     return 1;
    // }

    std::cout<<"Please enter the new base: ";
    std::cin >> newBase;
    if (newBase < 2 || newBase > 36){
        std::cout<<"invalid base";
        return 1;
    }
    newNumber = changeOfBase(oldBase, newBase, oldNumber);

    std::cout<<oldNumber <<" base " << oldBase <<" is " + newNumber <<" base " <<newBase;
};
