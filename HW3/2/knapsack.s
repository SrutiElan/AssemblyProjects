.global knapsack
.equ ws, 4

/*

unsigned int knapsack(int* weights, unsigned int* values, unsigned int num_items, 
              int capacity, unsigned int cur_value){

 */
.text
knapsack:
/*
ebp + 6: weights
ebp + 5: values
ebp + 4: num_items
ebp + 3: capacity
ebp + 2: cur_value
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
    .equ used_ebx, 0
    .equ used_esi, 1
    .equ used_edi, 1
    .equ num_saved_regs, (used_ebx + used_edi + used_esi)
	subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs
    
    .equ cur_value, (2*ws)
    .equ capacity, (3*ws)
    .equ num_items, (4*ws)
    .equ values, (5*ws)
    .equ weights, (6*ws)
	.equ i, (-1 * ws)
    .equ best_value, (-2 * ws)

    .equ old_ebx, (-3 * ws) # (%ebp)
    .equ old_edi, (-4 * ws) # (%ebp)
	.equ old_esi, (-5 * ws) # (%ebp)

    # save any calle saved regs
    movl %ebx, old_ebx(%ebp)
	movl %edi, old_edi(%ebp)
	movl %esi, old_esi(%ebp)

prologue_end:
    # edi will be i
    # ebx will be best_value

    # unsigned int i;
    @ movl i(%ebp), %edi
    movl $0, %edi
    # unsigned int best_value = cur_value;
    movl cur_value(%ebp), %ebx
    @ movl %ebx, best_value(%ebp)

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

        if_end:

        incl %edi # i++
        jmp for_loop_start
    for_loop_end:

