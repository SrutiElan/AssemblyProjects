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
  unsigned int mantissa1 = mantissa | (1 << 23); // Add the implicit 1
  unsigned int mantissa2 = rhs.mantissa | (1 << 23);

  /*
  compare exponents, the smaller one will be decreased to preserve precision
  ex) 3.25 * 10^2 + 4.3 * 10^-1
  4.3 * 10^-1 => 0.0043 * 10^2 (shift to right by 3, since we are incr exponent, shr decr )
  3.25 * 10^2 + 0.0043 * 10^2
  = (3.25 + 0.0043) * 10^2 (same exponent)

  if  3.25 * 10^2 + 4.3 * 10^-1
  2 + 1 = 3 > 0 so this exp is greater
  need to shift mantissa2 (right by diff)
  result exponent = this exponent

  if 4.3 * 10^-1 + 3.25 * 10^2
  -1 - 2 = -3 < 0, so rhs exp is greater
  need to shift mantissa1 (right by -diff)
  result exponent = rhs exponent
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
  if (sign == rhs.sign)
  {

    int diff = exponent - rhs.exponent;
    if (diff >= 0)
    {
      // exp > rhs.exp, so rhs mantissa shifts right
      mantissa2 >>= diff; // align this mantissa
      result.exponent = exponent;
    }
    else if (diff < 0)
    {
      // rhs.exp > exp, so this.mantissa shifts right

      int absDiff = -diff; // make positive
      mantissa1 >>= absDiff;

      result.exponent = rhs.exponent;
    }

    unsigned int mantissa_sum = mantissa1 + mantissa2;
    // if the 24th bit has a 1 then the mantissa overflowed
    while (mantissa_sum >= (1 << 24))
    { // check for carry
      mantissa_sum >>= 1;
      result.exponent++;
    }

    result.mantissa = mantissa_sum & (~(1 << 23)); // Drop the implicit 1
    result.sign = sign;                            // Assume same sign for simplicity
  }
  else
  { // diff signs

    //same as above
    int diff = exponent - rhs.exponent;
    if (diff >= 0)
    {
      // exp > rhs.exp, so rhs mantissa shifts right
      mantissa2 >>= diff; // align this mantissa
      result.exponent = exponent;
    }
    else if (diff < 0)
    {
      // rhs.exp > exp, so this.mantissa shifts right

      int absDiff = -diff; // make positive
      mantissa1 >>= absDiff;

      result.exponent = rhs.exponent;
    }


    // make sure mantissa1 is the larger magnitude
    if (mantissa1 < mantissa2)
    {
      std::swap(mantissa1, mantissa2);
      result.sign = rhs.sign; // result takes the sign of the larger magnitude
    }
    else
    {
      result.sign = sign;
    }

    unsigned int mantissa_diff = mantissa1 - mantissa2;

   
    /*
    A borrow occurs when the most significant bit shifted out of the smaller number's mantissa is a 1. 
    If this happens you will need to subtract an additional 1 from the difference between the two mantissas.
    */
    if ((mantissa2 & (1 << (diff - 1))) == 1)
    {
      mantissa_diff -= 1;
    }

    // normalize if necessary
    while ((mantissa_diff & (1 << 23)) == 0 && mantissa_diff != 0)
    {
      mantissa_diff <<= 1;
      result.exponent--;
    }

    result.mantissa = mantissa_diff & (~(1 << 23)); // Drop implicit 1
  }
  return result;
}

MyFloat MyFloat::operator-(const MyFloat &rhs) const
{
  MyFloat temp = rhs;
  temp.sign = -1;
  return *this + temp; 
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
  std::bitset<32> floatBits(*reinterpret_cast<unsigned int *>(&f));
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
  __asm__(
      "mov %[sign], %[f];" // load sign
      "shl $31, %[f];"     // shift left by 31 bits
      "mov %[exp], %%ecx;"
      "shl $23, %%ecx;" // shift exponent left by 23 bits
      "or %%ecx, %[f];"
      "or %[mant], %[f]" // combine mantissa

      : [f] "=r"(f)
      : [sign] "r"(sign), [exp] "r"(exponent), [mant] "r"(mantissa)
      : "ecx");

  return f;
} // packFloat
//
