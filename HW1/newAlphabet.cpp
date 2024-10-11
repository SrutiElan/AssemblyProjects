#include <iostream>
#include <string>

char decodeLetter(int encodedArg){
   unsigned int letterBits = encodedArg & 0b11111111111111111111111111;
    unsigned int isUppercase = (encodedArg >> 26) & 1;  // 27th bit for uppercase/lowercase
    char decodedChar = '\0';

    for (unsigned int i = 0; i < 26; ++i) {
        if (letterBits & (1 << i)) {
            decodedChar = 'a' + i;  // Find the letter corresponding to the set bit
            break;
        }
    }
    // Convert to uppercase if the 27th bit is set
    if (isUppercase && decodedChar != '\0') {
        decodedChar = std::toupper(decodedChar);
    }

    return decodedChar;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout<<"Need more arguments";
        return 1;
    }
    std::string decodeMessage;

    //iterate through the args. everytime there is a space that is a number
    for (int i = 1; i < argc; i++) {
        int encodedArg = atoi(argv[i]);
        char letter = decodeLetter(encodedArg);
            decodeMessage += letter;

    }
    //translate the numbers to letters
    //output: "The word you entered: "
    std::cout << "You entered the word: " << decodeMessage << std::endl;

    

}