#include "MyFloat.h"
#include <bitset> // Include for std::bitset

MyFloat::MyFloat()
{
  sign = 0;
  exponent = 0;
  mantissa = 0;
}

MyFloat::MyFloat(float f)
{
  unpackFloat(f);
}

MyFloat::MyFloat(const MyFloat &rhs)
{
  sign = rhs.sign;
  exponent = rhs.exponent;
  mantissa = rhs.mantissa;
}

ostream &operator<<(std::ostream &strm, const MyFloat &f)
{
  // this function is complete. No need to modify it.
  strm << f.packFloat();
  return strm;
}

MyFloat MyFloat::operator+(const MyFloat &rhs) const
{
  MyFloat result;
  uint64_t mantissa1 = mantissa | (1<<23); // Add the implicit 1
  uint64_t mantissa2 = rhs.mantissa | (1<<23);
 
  /*
  compare exponents, the larger one will be decreased to preserve precision
  ex) 3.25 * 10^2 + 4.3 * 10^-1 you dont want to make 0.0043 x 10^2 bc the last digits might be cut off
  3.25 * 10^2  =>  3250 * 10^-1 (shift to left by 3)
  3250 * 10^-1 + 4.3 * 10 ^-1 
  = (3250 + 4.3) * 10^-1 (same exponent)

  if  3.25 * 10^2 + 4.3 * 10^-1
  2 + 1 = 3 > 0 so this exp is greater
  need to shift mantissa1 (left by diff)
  result exponent = rhs exponent 

  if 4.3 * 10^-1 + 3.25 * 10^2
  -1 - 2 = -3 < 0, so rhs exp is greater
  need to shift mantissa2 (left by -diff)
  result exponent = this exponent
  */

 /*
 ./fpArithmetic.out 1.25 + 3.75

float: 1736217600 : 1.10011101111100100101000 x 2^30
float in bits: 01001110110011101111100100101000

Unpacked values: 
Sign: 0
Exponent: 157
Mantissa: 10011101111100100101000


float: 0.5 : 1.0 x 2^-1
float in bits: 00111111000000000000000000000000

Unpacked values: 
Sign: 0
Exponent: 126
Mantissa: 00000000000000000000000
1736217600 + 0.5
My Add: 1

 110011101111100100101000 :Mant 1
 1111100100101000000000000000000
 100000000000000000000000 :mant 2

 1001100000000000000000000
  100110000000000000000000
 */
    int diff = exponent - rhs.exponent;
    if (diff >= 0) {
      // exp > rhs.exp, so this mantissa shifts
        mantissa1 <<= diff; // align this mantissa
        result.exponent = rhs.exponent;

    } else if (diff < 0) {
      // rhs.exp > exp, so rhs.mantissa shifts
      
        int absDiff = -diff; // Make positive      
        mantissa2 <<= absDiff;
       
        result.exponent = exponent;
    }

    uint64_t mantissa_sum = mantissa1 + mantissa2;
    // if the 24th bit has a 1 then the mantissa overflowed
    while (mantissa_sum >= (1<<24)) { // check for carry
        mantissa_sum >>= 1;
        result.exponent++;
    }

    result.mantissa = mantissa_sum & (~(1<<23)); // Drop the implicit 1
    result.sign = sign; // Assume same sign for simplicity
    return result;
  }

MyFloat MyFloat::operator-(const MyFloat &rhs) const
{

  return *this; // you don't have to return *this. it's just here right now so it will compile
}

bool MyFloat::operator==(const float rhs) const
{
  return false; // this is just a stub so your code will compile
}

void MyFloat::unpackFloat(float f)
{
  // this function must be written in inline assembly
  // extracts the fields of f into sign, exponent, and mantissa
  /*
  Bit 31 for the sign.
  Bits 30-23 for the exponent.
  Bits 22-0 for the mantissa.
  */
  __asm__(
      // read 1 bit from float starting at bit 31, put the result in sign
      "movb $1, %%ch;"
      "movb $31, %%cl;"
      "bextr %%ecx,%[f], %[sign];"

      // read 8 bits from float starting at bit 23, put result in exponent
      "movb $8, %%ch;"
      "movb $23, %%cl;"
      "bextr %%ecx,%[f], %[exp];"

      // read 23 bits from float starting at bit 0, put result in exponent
      "movb $23, %%ch;"
      "movb $0, %%cl;"
      "bextr %%ecx,%[f], %[mant];"

      :
      [sign] "=r"(sign), [exp] "=r"(exponent), [mant] "=r"(mantissa) : // outputs
      [f] "r"(f) :                                                     // copy float into eax
      "%ecx");
 
  std::cout << "\n\nfloat: " << f << std::endl;
  std::bitset<32> floatBits(*reinterpret_cast<unsigned int*>(&f));
  std::cout << "float in bits: " << floatBits << std::endl;
  std::cout << "\nUnpacked values: " << std::endl;
  std::cout << "Sign: " << sign << std::endl;
  std::cout << "Exponent: " << exponent << std::endl;
  std::bitset<23> mantissaBits(mantissa);
  std::cout << "Mantissa: " << mantissaBits << std::endl;

} // unpackFloat

float MyFloat::packFloat() const
{
  // this function must be written in inline assembly
  // returns the floating point number represented by this
  /*
  sign: shift left by 31 bits
  exponent: shift left by 23 bits
  mantissa : shift left by 0 bits
  */

  float f = 0;
  __asm__ (
    "mov %[sign], %[f];" // load sign
    "shl $31, %[f];" // shift left by 31 bits
    "mov %[exp], %%ecx;"
    "shl $23, %%ecx;" //shift exponent left by 23 bits
    "or %%ecx, %[f];" 
    "or %[mant], %[f]" //combine mantissa

    : [f]"=r" (f)
    : [sign]"r"(sign), [exp] "r" (exponent), [mant] "r" (mantissa)
     : "ecx" 
  );

  return f;
} // packFloat
//
