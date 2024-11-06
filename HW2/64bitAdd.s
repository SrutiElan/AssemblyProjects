/*
Add two 64 bit numbers together

num1: The first 64 bit number to add
Label Name: num1
Size: 64 bits
num2: The second 64 bit number to add
Label Name: num2
Size: 64 bits

1) use movl to move the lower 32 bit part of num1 to EAX, and higher 32 bit part to EDX
2) use ADC whic is the add instruction that adds the carry flag from the first ADD

or... 
ADD num1.low + num2.low = sum.low 
carry bit:
    if sum.low is < num1.low or num2.low, then carry = 1 else carry 0

Add num1.high + num2.high = sum.high 
ADD sum.high + carry = sum.high

Finally move sum.low to EAX and sum.high to EDX


Sources used:
* to understand how arithmetic works: https://stackoverflow.com/questions/1652654/adding-64-bit-numbers-using-32-bit-arithmetic, http://blog.flingos.co.uk/posts/217
 */
.global _start

.data

num1: .quad 0x0000000000000000
num2: .quad 0x0000000000000000

.text
//1) use movl to move the lower 32 bit part of num1 to EAX, and higher 32 bit part to EDX

_start: 
    movl num1+4, %eax        # move lower 32 bits of num1 into EAX
    movl num2+4, %ebx        # move lower 32 bits of num2 into EBX
    addl %ebx, %eax        # EAX = EBX + EAX

    # save the carry flag and load the upper 32 bits
    movl num1, %edx      #  upper 32 bits of num1 into EDX
    movl num2, %ecx      #  upper 32 bits of num2 into ECX
    adcl %ecx, %edx        # EDX = EDX + ECX , EDX = EDX + Carry from prev 

done:
    nop
