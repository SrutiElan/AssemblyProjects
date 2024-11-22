
.global get_combs, combinationUtil
.equ ws, 4


/*
void combinationUtil(int items[], int len, int k, int index, int data[], int i, int** result, int* comb_index) {
    // Base case: If the current combination is of size r, store it in the result itemsay
    if (index == k) {
        for (int j = 0; j < k; j++) {
            result[*comb_index][j] = data[j];
        }
        (*comb_index)++;
        return;
    }

    // If no more elements are left
    if (i >= len)
        return;

    // Include current element
    data[index] = items[i];
    combinationUtil(items, len, k, index + 1, data, i + 1, result, comb_index);

    // Exclude current element
    combinationUtil(items, len, k, index, data, i + 1, result, comb_index);
}

int** get_combs(int* items, int k, int len) {
    int numCombs = num_combs(len, k);

    // Allocate memory for storing the combinations
    int** result = (int**)malloc(numCombs * sizeof(int*));
    for (int i = 0; i < numCombs; i++) {
        result[i] = (int*)malloc(k * sizeof(int));
    }

    int* currComb = (int*)malloc(k * sizeof(int));  // Array to store current combination
    int comb_index = 0;  // To track the row in result

    // Call the recursive helper function
    combinationUtil(items, len, k, 0, currComb, 0, result, &comb_index);

    free(currComb);  // Free the temporary combination array
    return result;  // Return the result array
}


 */


.text

get_combs:
/*
ebp + 4: len
ebp + 3: k
ebp + 2: items
ebp + 1: ret
ebp : old ebp
ebp - 1: numCombs
ebp - 2: result
ebp - 3: i
ebp - 4: currComb
ebp - 5: combIndex
 */

prologue_start:
    push %ebp
    movl %esp, %ebp

    .equ num_locals, 5
    .equ used_ebx, 0
    .equ used_esi, 0
    .equ used_edi, 1
    .equ num_saved_regs, (used_ebx + used_edi + used_esi)
	subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs
    
    .equ len, (4*ws)
    .equ k, (3*ws)
    .equ items, (2*ws)
    .equ numCombs, (-1*ws)
    .equ result, (-2*ws)
    .equ i, (-3*ws)
    .equ currComb, (-4*ws)
    .equ combIndex, (-5*ws)

    .equ old_edi, (-6 * ws) # (%ebp)
    # .equ old_ebx, (-7 * ws) # (%ebp)
	# .equ old_esi, (-8 * ws) # (%ebp)

    # save any callee saved regs
    
	movl %edi, old_edi(%ebp)
    # movl %ebx, old_ebx(%ebp)
	# movl %esi, old_esi(%ebp)

prologue_end:
    # edi will be i

    # int numCombs = num_combs(len, k);
    movl k(%ebp), %ecx
    push %ecx 
    movl len(%ebp), %ecx
    push %ecx
    call num_combs
    addl $2*ws, %esp # clear function args
    # result is in eax
    movl %eax, numCombs(%ebp)

    # int** result = (int**)malloc(numCombs * sizeof(int*));
    shll $2, %eax # eax = numCombs * sizeof(int*)
    push %eax
    call malloc
    addl $1*ws, %esp # clear function args
    # result is in eax
    movl %eax, result(%ebp)

    # for (int i = 0; i < numCombs; i++) {
    movl $0, %edi # i = 0
    for_loop_start:
        # i < numCombs
        # neg: i - numCombs >= 0
        cmpl numCombs(%ebp), %edi # i - numCombs
        jae for_loop_end

        # result[i] = (int*)malloc(k * sizeof(int));
        movl k(%ebp), %eax # eax = k
        shll $2, %eax # eax = k * sizeof(int*)
        push %eax    
        call malloc
        addl $1*ws, %esp # clear function args
        # result is in eax
        movl result(%ebp), %ecx # ecx = result[0]
        movl %eax, (%ecx, %edi, ws) # result[i] = ...

        incl %edi # i++
        jmp for_loop_start
    for_loop_end:

    #  int* currComb = (int*)malloc(k * sizeof(int));  // Array to store current combination
    movl k(%ebp), %eax # eax = k
    shll $2, %eax # eax = k * sizeof(int*)
    push %eax    
    call malloc
    addl $1*ws, %esp # clear function args
    # result is in eax
    movl %eax, currComb(%ebp) # currComb = eax

    # int comb_index = 0;  // To track the row in result
    movl $0, comb_index(%ebp)

    # combinationUtil(items, len, k, 0, currComb, 0, result, &comb_index);
    leal comb_index(%ebp), %ecx # ecx = &comb_index
    push %ecx
    push result(%ebp)
    push $0
    push k(%ebp)
    push len(%ebp)
    push items(%ebp)

    call combinationUtil
    addl $6*ws, %esp # clear function args
    # result is in eax
    movl %eax, result(%ebp) # result = eax
    movl result(%ebp), %eax # eax = result (do i need this line?)

epilogue_start:
    # restore saved regs
    movl old_edi(%ebp), %edi
    # movl old_esi(%ebp), %esi
    # movl old_ebx(%ebp), %ebx

    movl %ebp, %esp # clear space for locals, args, and scratch 
    pop %ebp 
    ret 
epilogue_end:



combinationUtil:

    # ebp + 9: comb_index
    # ebp + 8: result
    # ebp + 7: i
    # ebp + 6: data
    # ebp + 5: index
    # ebp + 4: k
    # ebp + 3: len
    # ebp + 2: items
    # ebp + 1: ret
    # ebp : old_ebp
    # ebp - 1: j

combination_util_prologue_start:
    push %ebp # save old ebp
    movl %esp, %ebp # establlish stack frame

    .equ num_locals, 1
    .equ used_ebx, 1
    .equ used_esi, 1
    .equ used_edi, 1
    .equ num_saved_regs, (used_ebx + used_edi + used_esi)
	subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs
    
    .equ comb_index, (9*ws)
    .equ result, (8*ws)
    .equ i, (7*ws)
    .equ data, (6*ws)
    .equ index, (5*ws)
    .equ k, (4*ws)
    .equ len, (3*ws)
    .equ items, (2*ws)
	.equ j, (-1 * ws)

    .equ old_ebx, (-2 * ws) # (%ebp)
    .equ old_edi, (-3 * ws) # (%ebp)
	.equ old_esi, (-4 * ws) # (%ebp)

    # save any callee saved regs
    movl %ebx, old_ebx(%ebp)
	movl %edi, old_edi(%ebp)
	movl %esi, old_esi(%ebp)

combination_util_prologue_end:  
    # ebx will be j

    base_case_start:   
    # if (index == k) {
    movl index(%ebp), %ecx # ecx = index
    cmpl %ecx, k(%ebp) # k - index 
    jne base_case_end
        # for (int j = 0; j < k; j++) {
        movl $0, %ebx # j = 0
        c_for_loop_start:
            # if j >= k , break  
            # j - k >= 0 break 
            cmpl k(%ebp), %ebx # j - k 
            jae c_for_loop_end
            
            # result[*comb_index][j] = data[j];
            # *(*(result + *comb_index) + j) = data[j]

            # data[j]
            movl data(%ebp), %ecx # ecx = data[0]
            movl (%ecx, %ebx, ws), %ecx # ecx = data[j]

            # *(result + *comb_index)
            movl comb_index(%ebp), %edx # edx = address of comb_index
movl (%edx), %edx           # edx = *comb_index
movl result(%ebp), %eax     # eax = base address of result
movl (%eax, %edx, ws), %eax # eax = result[*comb_index] (address of the row)
movl %ecx, (%eax, %ebx, ws) # *(result[*comb_index] + j) = data[j]

        
            incl %ebx # j++
            jmp c_for_loop_start
        c_for_loop_end:
            # (*comb_index)++;
            movl comb_index(%ebp), %edx # edx = comb_index
            movl (%edx), %ecx # ecx = *comb_index
            incl %ecx # ecx = *comb_index + 1
            movl %ecx, (%edx) # *comb_index = ebx

            jmp combination_util_epilogue_start
    base_case_end:

    # if (i >= len), return
    # i - len >= 0 
    movl len(%ebp), %ecx # ecx = len
    cmpl %ecx, i(%ebp) # i - len
    jae combination_util_epilogue_start

    # data[index] = items[i];
    # items[i]
    movl items(%ebp), %ecx # ecx = items[0]
    movl i(%ebp), %edx # edx = i
    movl (%ecx, %edx, ws), %ecx # ecx = items[i]

    # data[index]
    movl data(%ebp), %eax # eax = data[0]
    movl index(%ebp), %edx # edx = index
    movl (%eax, %edx, ws), %eax # eax = data[index]

    movl %ecx, (%eax) # data[index] = items[i]

    # combinationUtil(items, len, k, index + 1, data, i + 1, result, comb_index);
    push comb_index(%ebp)
    push result(%ebp)
    movl i(%ebp), %edx # edx = i
    incl %edx # edx = i + 1
    push %edx
    push data(%ebp)
    movl index(%ebp), %edx # edx = index
    incl %edx # edx = index + 1 
    push %edx
    push k(%ebp)
    push len(%ebp)
    push items(%ebp)
    call combinationUtil
    addl $8*ws, %esp # clear arguments

    # combinationUtil(items, len, k, index, data, i + 1, result, comb_index);
    push comb_index(%ebp)
    push result(%ebp)
    movl i(%ebp), %edx # edx = i
    incl %edx # edx = i + 1
    push %edx
    push data(%ebp)
    push index(%ebp)
    push k(%ebp)
    push len(%ebp)
    push items(%ebp)
    call combinationUtil
    addl $8*ws, %esp # clear arguments

combination_util_epilogue_start:
    # restore saved registers
    movl old_edi(%ebp), %edi
	movl old_esi(%ebp), %esi
    movl old_ebx(%ebp), %ebx

    movl %ebp, %esp # clear space for locals, args, and scratch 
    pop %ebp
    ret

combination_util_epilogue_end:
