.global _start

.data
    dividend: //eax
        .long 4294967295
    divisor: //ebx
        .long 32


.text
_start:
    movl dividend, %ecx        # ecx contains dividend
    movl divisor, %ebx         # EBX contains divisor

    movl $0, %ecx             # quotient = 0
    movl $0, %edx  
    movl %ecx, %edx            # remainder = dividend

    movl %ebx, %esi            # tempDivisor = divisor

shift_while_start:
    movl %esi, %edi            # Save current tempDivisor (edi = old tD)
    shll $1, %esi              # Left shift tempDivisor <<= 1

    cmpl %edi, %esi            # Check for wrapping (tempDivisor << 1 <= old tempDivisor)
    jle shift_while_end
    cmpl %ecx, %esi            # Check if (tempDivisor << 1) > dividend
    jg shift_while_end
    jmp shift_while_start

shift_while_end:
    movl %edi, %esi            # Restore correct tempDivisor from previous

while_start:
    cmpl %ebx, %esi            # Check if tempDivisor >= divisor
    jl while_end

    cmpl %esi, %edx            # Check if remainder >= tempDivisor
    jl else_start

    subl %esi, %edx            # remainder -= tempDivisor
    shll $1, %eax              # quotient <<= 1
    orl $1, %eax               # quotient |= 1
    jmp end_else

else_start:
    shll $1, %eax              # quotient <<= 1

end_else:
    shrl $1, %esi              # tempDivisor >>= 1
    jmp while_start

while_end:
    
done:
    nop
