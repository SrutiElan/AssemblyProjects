.global knapsack
.equ ws, 4

/*

unsigned int knapsack(int* weights, unsigned int* values, unsigned int num_items, 
              int capacity, unsigned int cur_value){

 */
.text

# unsigned int max(unsigned int a, unsigned int b)
max: 
    # eax has a 
    # edx has b
    # return a > b ? a : b;
    # if a - b > 0 return a if <= 0 then return b
    cmpl %edx, %eax # a - b
    ja max_end
    movl %edx, %eax # eax = b
max_end:
    ret 


knapsack:
/*
ebp + 6: cur_value
ebp + 5: capacity
ebp + 4: num_items
ebp + 3: values
ebp + 2: weights
ebp + 1: ret
ebp : old ebp
ebp - 1: i
ebp - 2: best_value
ebp - 3: old_ebx
ebp - 4: old_edi
ebp - 5: old_esi

 */

prologue_start:
    push %ebp # save old ebp
    movl %esp, %ebp # establlish stack frame

    .equ num_locals, 2
    .equ used_ebx, 1
    .equ used_esi, 1
    .equ used_edi, 1
    .equ num_saved_regs, (used_ebx + used_edi + used_esi)
	subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs
    
    .equ cur_value, (6*ws)
    .equ capacity, (5*ws)
    .equ num_items, (4*ws)
    .equ values, (3*ws)
    .equ weights, (2*ws)
	.equ i, (-1 * ws)
    .equ best_value, (-2 * ws)

    .equ old_ebx, (-3 * ws) # (%ebp)
    .equ old_edi, (-4 * ws) # (%ebp)
	.equ old_esi, (-5 * ws) # (%ebp)

    # save any callee saved regs
    movl %ebx, old_ebx(%ebp)
	movl %edi, old_edi(%ebp)
	movl %esi, old_esi(%ebp)

prologue_end:
    # edi will be i
    # ebx will be best_value

    # unsigned int i;
    # @ movl i(%ebp), %edi
    movl $0, %edi
    # unsigned int best_value = cur_value;
    movl cur_value(%ebp), %ebx
    movl %ebx, best_value(%ebp)

    # for(i = 0; i < num_items; i++)
    for_loop_start:
        # i - num_items < 0
        # neg: i - num_items >= 0
        cmpl num_items(%ebp), %edi # i - num_items
        jae for_loop_end

        # if(capacity - weights[i] >= 0 )
        if_start:
            movl weights(%ebp), %ecx # ecx = Weights
            movl (%ecx, %edi, ws), %ecx # ecx = weights[i]

            # neg: capacity - weights[i] < 0 , then break
            cmpl %ecx, capacity(%ebp) # capacity - weights[i] < 0
            jb if_end

            /* best_value = max(best_value, knapsack(weights + i + 1, values + i + 1, num_items - i - 1, 
                     capacity - weights[i], cur_value + values[i])); */
            
            /*  knapsack(weights + i + 1, values + i + 1, num_items - i - 1, 
                     capacity - weights[i], cur_value + values[i]) */
            
            # push cur_value + values [i] 
            movl values(%ebp), %ecx # ecx = values
            movl (%ecx, %edi, ws), %ecx # ecx = values[i]
            addl cur_value(%ebp), %ecx # ecx = cur_value + values[i]
            push %ecx # put arg on stack

            # push capacity - weights[i]
            movl weights(%ebp), %ecx # ecx = Weights
            movl (%ecx, %edi, ws), %ecx # ecx = weights[i]
            movl capacity(%ebp), %edx    # edx = capacity
            subl %ecx, %edx # edx = capacity - weights[i]
            push %edx # put arg on stack

            # push num_items - i - 1
            movl num_items(%ebp), %ecx # ecx = num_items
            subl %edi, %ecx # ecx = num_items - i
            decl %ecx # ecx = num_items - i -1
            push %ecx # put arg on stack

            # push values + i + 1
            movl values(%ebp), %ecx # ecx = values
            leal 1*ws(%ecx, %edi, ws), %ecx # ecx = values + i + 1
            push %ecx

            # push weights + i + 1
            movl weights(%ebp), %ecx # ecx = weights
            leal $1*ws(%ecx, %edi, ws), %ecx # ecx = weights + i + 1
            push %ecx
            call knapsack

            addl $5*ws, %esp # clear function arguments
            # eax = knapsack(...)

            /* best_value = max(best_value, knapsack(...)); */
            movl %eax, %edx # edx = knapsack (...)
            movl best_value(%ebp), %eax # eax = best_value
            call max
            movl %eax, best_value(%ebp) # Update best_value
            # eax = best_value
        if_end:

        incl %edi # i++
        jmp for_loop_start
    for_loop_end:
        movl best_value(%ebp), %eax
epilogue_start:
    # restore saved registers
    movl old_edi(%ebp), %edi
	movl old_esi(%ebp), %esi
    movl old_ebx(%ebp), %ebx

    movl %ebp, %esp # clear space for locals, args, and scratch 
    pop %ebp
    ret

epilogue_end:
