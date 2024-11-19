/*
    int rec_sum(int* nums, int len){
        if(len == 0){
            return 0;
        }else{
            return nums[0] + rec_sum(nums + 1, len - 1)
        }
    
    }

*/ 


.global rec_sum
.equ ws, 4
.text 
rec_sum:
    
    # ebp + 3: len
    # ebp + 2 : nums
    # ebp + 1 : return address
    # ebp: old ebp 

    prologue_start:
        push %ebp
        movl %esp, %ebp 
		;# make space for locaosl and saved regs
		;# saved regs

    .equ num_locals, 0
	.equ used_ebx, 0
	.equ used_esi, 0
	.equ used_edi, 0
	.equ num_saved_regs, (used_ebx + used_edi + used_esi)
	subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs
    
    .equ len, (3 * ws) #(%ebp)
    .equ nums, (2 * ws) #(%ebp)

        # save any callee saved regs 

    prologue_end:

    // if(len == 0)

    movl len(%ebp), %ecx # ecx = len
		// if(len == 0)
		# len == 0 | len - 0 == 0
		# negation:  len-0 != 0
		
    cmpl $0, %ecx # len - 0
    jne recursive_case_start
    
    base_case_start:
        #  return 0;
        movl $0, %eax 
        jmp epilogue_start

    base_case_end:

    recursive_case_start:
        # return nums[0] + rec_sum(nums + 1, len - 1)
        decl %ecx # ecx = len -1
        push %ecx # put arg on stack 

        movl nums(%ebp), %edx # edx = nums
        
        # wrong : incl %edx # edx = edx + 1  
        /**
            edx is a pointer, nums is a pointer
            so u have to use leal
            1*ws(%edx)
            d + o + i * s = 4 + nums + 0 * 1 
            nums + 1 won't work, you need to do nums + 4 because an integer is 4 bytes
            !!!!! explain again
            why wouldn't it go to nums + 4 aka len instead of nums + 4 as the integer
         */
        leal 1*ws(%edx), %edx # edx = nums + 1
        push %edx # put arg on the stack 
        call rec_sum # eax = rec_sum(nums + 1, len - 1)
        addl $2*ws, %esp # clear function arguments 
        # eax = rec_sum(nums + 1, len - 1)


        addl nums(%ebp), %eax 
        /**
        won't work bc this is adding address of nums on stack so if ebp is at 100, this would be 100 + 2
        instead you want address of nums, which is ex) 5000
        **/

        movl nums(%ebp), %edx # edx = nums (edx = 5000 ) WHY IS THIS NOT EDX = 102 
        addl (%edx), %eax # eax = nums[0] + rec_sum(nums + 1, len - 1) 
        # (%edx) dereferences 5000 so that it is nums[0]
        # cannot do addl (nums(%ebp)), %eax because it is accessing memory twice

    recursive_case_end:

    epilogue_start:
	    # restore saved registers
        movl %ebp, %esp # clear locals, args, and scrach space 
        pop %ebp 
        ret 

/*
p ((int**))$ebp)[2][0]@((int*)$ebp)[3]
left of 2 gives pointer nums 
first element of nums is [0] 

the second part ((int*)$ebp)[3] is the same as len 
so you are saying
p nums[0]@len 

//4 c
//3 b
//2 a
//1 ret
//ebp: old ebp
* short will tell you to read 2 bytes 
* but u need to move 16 bytes past ebp

//c
ar[0] = *(ar + 0) == *ar

p ((short*))((int*)$ebp + 4)[0]
    move 4 ints = 16 bytes past ebp, and then since it's a short read 2 bytes
 or 
p ((short*)$ebp)[8]

//b
p ((char*)((int*)$ebp + 3))[0]

p ((char*)$ebp)[12]

computer cpu components
* what regsiters stores what
* MDR MAR
push pop call ret actually do
everythign that showed in first mideterm
why a program compiled on one machine might not work on another
* os may be different

prologue: 
puish ebp
movl esp ebp
make space for local vars
save registers

gcc call
* how arg is passed in functioN: pushed in reverse order
returned: eax
who is responsoble for saving what register:
* caller does A D C
* callee does everything else

is it important that all stages in pipeline take same amount of time? why or why not?

ar + i dereferenced = Ar i - 12 
ar + i - 12*4 
movl 128, 

do 18 and earlier in practice q

how do u access the arguments of a function 2 functions above me
 */