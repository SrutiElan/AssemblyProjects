/*
Place the quotient in EAX
Place the remainder in EDX
Shifting by a Variable Amount In x86 Assembly
If you want to shift by a variable amount, that shift amount must be placed in CL. Your assembly code won't work if you try to place it in any other register.

 */

.global _start

.data
    dividend: //eax
        .long 4294967295
    divisor: //ebx
        .long 37228
    quotient: //ecx
        .long 0
    remainder: //edx
        .long 0
    
.text
_start:
    movl dividend, %eax # EAX contains dividend
    movl divisor, %ebx # EBX contains divisor

    movl $0, %ecx # quotient = 0
    movl %eax, %edx # remainder

    movl %ebx, %esi # tempDivisor is in ESI

    shift_while_start:
   
    /*
        while (true) {
            if ((tempDivisor << 1) <= tempDivisor) 
            || (tempDivisor << 1) > dividend) {
            break;
            }
            tempDivisor <<= 1;
        }
    */
    movl %esi, %edi  # oldtD (EDI) = tD
    shll $1, %esi # ESI: tempDivisor<<=1

    #  if ((tempDivisor << 1) <= tempDivisor) 
        # tempDiviesisor<<1 <= oldtempDivisor ==> TD<<1 - oldTD <= 0
        cmpl %edi, %esi # esi - edi == TD<<1 - oldTD  
        jbe shift_while_end # jump if <= 0
    # if (tempDivisor << 1) > dividend)
        # tD - dividend > 0 
        cmpl %eax, %esi # esi - eax == tD - dividend
        ja shift_while_end # jump if above 0
    
    jmp shift_while_start
    
    shift_while_end:
    movl %edi, %esi # esi holds correct tD

    while_start:
        #  while (tempDivisor >= divisor) 
        /* while (true) {
            if (tD < divisor)
                break;
            code
        }
        */

        # td < divisor => td - divisor < 0 
        cmpl %ebx, %esi # esi - ebx 
        jb while_end #---------------------- #jump if below 0

        /*
         if (remainder >= tempDivisor){
            remainder -= tempDivisor;
            quotient = (quotient << 1) | 1;
         }
         => if (remainder < tD) jump to else
         */

         # remainder < tD => remainder - tD < 0
        cmpl %esi, %edx # edx - esi 
        
        jb else_start #-----

        # remainder = remainder - tempDivisor;
        sub %esi, %edx # edx = edx - esi

        # quotient = (quotient << 1) | 1;
        shll $1, %ecx # quotient (ECX) = quotient << 1
        orl $1, %ecx # ecx = ecx or 1
        jmp end_else # --------------------

        else_start: # remainder < tempDivisor
         # quotient <<=1
            shll $1, %ecx # quotient (ECX) = quotient << 1
        
        end_else:
        # tempDivisor >>=1;
        shrl $1, %esi 
        jmp while_start
    while_end:

    movl %ecx, %eax # eax = ecx


done:
    nop
 