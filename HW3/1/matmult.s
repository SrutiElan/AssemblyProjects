/*
    int** matMult(int **a, int num_rows_a, int num_cols_a, int** b, 
                int num_rows_b, int num_cols_b);		
        
		int** C = (int**) malloc( num_rows_a * sizeof(int*));
        for (int i = 0; i < num_rows_a; i++) {
            C[i] = (int*) malloc(num_cols_b * sizeof(int));
            for (int j = 0; j < num_cols_b; j++) {
                C[i][j] = 0;
                for (int k = 0; k < num_cols_a; k++) {
                    C[i][j] += A[i][k] * B[k][j];
                }
        }
        return C;
	}
*/

.global matMult
.equ ws, 4

.text

matMult:
    # ebp + 7: num_cols_b
    # ebp + 6: num_rows_b
    # ebp + 5: B
    # ebp + 4: num_cols_a
	# ebp + 3: num_rows_a
	# ebp + 2: A
	# ebp + 1: return address
    # ebp: old ebp
    # ebp - 1: i
    # ebp - 2: j
    # ebp - 3: k
    # ebp - 4: C
    # ebp - 5: edi
    # ebp - 6: esi
    # ebp - 7: ebx


    prologue_start:
        push %ebp # save old ebp
		movl %esp, %ebp # establish stack frame for this function

        .equ num_locals, 4
		.equ used_ebx, 1
		.equ used_esi, 1
		.equ used_edi, 1
		.equ num_saved_regs, (used_ebx + used_edi + used_esi)
		subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs
        
        .equ A, (2 * ws) #(%ebp)
		.equ num_rows_a, (3 * ws) #(%ebp)
		.equ num_cols_a, (4 * ws) #(%ebp)
        .equ B, (5 * ws) #(%ebp)
		.equ num_rows_b, (6 * ws) #(%ebp)
		.equ num_cols_b, (7 * ws) #(%ebp)
		.equ i, (-1 * ws) #(%ebp)
		.equ j, (-2 * ws) #(%ebp)
		.equ k, (-3 * ws) #(%ebp)
        .equ C, (-4 * ws) #(%ebp)

		.equ old_edi, (-5 * ws) # (%ebp)
		.equ old_esi, (-6 * ws) # (%ebp)
        .equ old_ebx, (-7 * ws) # (%ebp)


		# save any calle saved regs
		movl %edi, old_edi(%ebp)
		movl %esi, old_esi(%ebp)
        movl %ebx, old_ebx(%ebp)


	prologue_end:
	# ecx will be i
    # edi will be j
    # edx will be C

    # int** C = (int**) malloc( num_rows_a * sizeof(int*));
    // movl $4, %eax 
	// imull num_rows(%ebp)
	// push %eax 

    movl num_rows_a(%ebp), %eax 
    shll $2, %eax # eax = num_rows_a * sizeof(int*)
	push %eax # set the argument to malloc
	call malloc
	addl $1*ws, %esp # remove the argument to malloc from the stack
	movl %eax, C(%ebp) # C = (int**) malloc( num_rows_a * sizeof(int*))

    # for(i = 0; i < num_rows_a; ++i)
	movl $0, %ecx # i = 0

	outer_for_start:
		# i < num_rows_a
		# i - num_rows_a < 0
		# neg: i - num_rows_a >= 0

		cmpl num_rows_a(%ebp), %ecx # i - num_rows
		jge outer_for_end

        # save ecx (i) before the function call to malloc
		# beacause we are now the caller 
		movl %ecx, i(%ebp)

		# C[i] = (int*)malloc( num_cols_b * sizeof(int));
        movl num_cols_b(%ebp), %eax # eax = num_cols
        shll $2, %eax # eax = num_cols * sizeof(int)
		push %eax # set the argument to malloc
		call malloc # eax = (int*)malloc( num_cols * sizeof(int))
		addl $1 *ws, %esp # clear malloc's argument
		movl C(%ebp), %edx # edx = C
		movl i(%ebp), %ecx # restore ecx back to i
		movl %eax, (%edx, %ecx, ws) # C[i] = (int*)malloc( num_cols * sizeof(int))

        # edi will be j
		movl $0, %edi # j = 0
        # for (int j = 0; j < num_cols_b; j++) {
		inner_for_start:
			# j - num_cols_b < 0
			# neg: j - num_cols_b >= 0
			cmpl num_cols_b(%ebp), %edi # j - num_cols_b
			jge inner_for_end

            # C[i][j] = 0;
            # *(*(C + i) + j) = 0
            movl C(%ebp), %edx # edx = C
            movl (%edx, %ecx, ws), %edx # edx = C[i]
            movl $0, (%edx, %edi, ws) # C[i][j] = 0

            # esi will be k
            movl $0, %esi # k = 0 
            # for (int k = 0; k < num_cols_a; k++) 
            k_for_start:
                # k - num_cols_a < 0
                # neg: k - num_cols_a >= 0
                cmpl num_cols_a(%ebp), %esi # k - num_cols_a
                jge k_for_end    

                # C[i][j] += A[i][k] * B[k][j];
                # *(*(C + i) + j) = *(*(C + i) + j) + [*(*(A + i) + k) * *(*(B + i) + k)]
               
                # A[i][k] == *(*(A + i) + k)
                movl A(%ebp), %eax # eax = A
                movl (%eax, %ecx, ws), %eax # eax = A[i]
                movl (%eax, %esi, ws), %eax # eax = A[i][k]

                # B[k][j] ==  *(*(B + k) + j)
                movl B(%ebp), %ebx # ebx = B
                movl (%ebx, %esi, ws), %ebx # ebx = B[k]
                imull (%ebx, %edi, ws), %eax # eax = A[i][k] * B[k][j]

                movl C(%ebp), %ebx # ebx = C
                movl (%ebx, %ecx, ws), %ebx # edx = C[i]
                addl %eax, (%ebx, %edi, ws) # C[i][j] = C[i][j] + A[i][k] * B[k][j]
        

                incl %esi
                jmp k_for_start
            k_for_end:

			incl %edi 
			jmp inner_for_start
		inner_for_end:

		incl %ecx 
		jmp outer_for_start
	outer_for_end:

    # return C;
    movl C(%ebp), %eax # set the return value

    epilogue_start:
		# restore saved regs
		movl old_edi(%ebp), %edi
		movl old_esi(%ebp), %esi
        movl old_ebx(%ebp), %ebx

		movl %ebp, %esp # clear space for locals, args, and scratch 
		pop %ebp 
		ret 
	epilogue_end:
