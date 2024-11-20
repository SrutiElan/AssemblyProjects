
/*
	int** matadd(int** A, int** B, int num_rows, int num_cols){
		int i, j;
		int** C = (int**) malloc( num_rows * sizeof(int*));
		for(i = 0; i < num_rows; ++i){
			C[i] = (int*)malloc( num_cols * sizeof(int));
			for(j = 0; j < num_cols; ++j){
				C[i][j] = A[i][j] + B[i][j];
			}
		}
		return C;
	}
*/


.global matadd
.equ ws, 4

.text 

matadd:

	# ebp + 5: num_cols
	# ebp + 4: num_rows
	# ebp + 3: B
	# ebp + 2: A
	# ebp + 1: return address
	# ebp: old ebp
	# ebp - 1: i
	# ebp - 2: j
	# ebp - 3: C
	# ebp - 4: old esi
	# ebp - 5: old edi

	prologue_start:
		push %ebp # save old ebp
		movl %esp, %ebp # establish stack frame for this function

		.equ num_locals, 3
		.equ used_ebx, 0
		.equ used_esi, 1
		.equ used_edi, 1
		.equ num_saved_regs, (used_ebx + used_edi + used_esi)
		subl $(num_locals + num_saved_regs) * ws, %esp # make space for locals and saved regs


		.equ A, (2 * ws) #(%ebp)
		.equ B, (3 * ws) #(%ebp)
		.equ num_rows, (4 * ws) #(%ebp)
		.equ num_cols, (5 * ws) #(%ebp)
		.equ i, (-1 * ws) #(%ebp)
		.equ j, (-2 * ws) #(%ebp)
		.equ C, (-3 * ws) #(%ebp)
		.equ old_edi, (-4 * ws) # (%ebp)
		.equ old_esi, (-5 * ws) # (%ebp)

		# save any calle saved regs
		movl %edi, old_edi(%ebp)
		movl %esi, old_esi(%ebp)



	prologue_end:
	# ecx will be i

	#  C = (int**) malloc( num_rows * sizeof(int*))
	// movl $4, %eax 
	// imull num_rows(%ebp)
	// push %eax 

	movl num_rows(%ebp), %eax # eax = num_rows


	shll $2, %eax # eax = num_rows * sizeof(int*)
	push %eax # set the argument to malloc
	call malloc
	addl $1*ws, %esp # remove the argument to malloc from the stack
	movl %eax, C(%ebp) # C = (int**) malloc( num_rows * sizeof(int*))

	# for(i = 0; i < num_rows; ++i)
	movl $0, %ecx # i = 0

	outer_for_start:
		# i < num_rows
		# i - num_rows < 0
		# neg: i - num_rows >= 0

		cmpl num_rows(%ebp), %ecx # i - num_rows
		jge outer_for_end


		# save ecx (i) before the function call to malloc
		# beacause we are now the caller 
		movl %ecx, i(%ebp)

		# C[i] = (int*)malloc( num_cols * sizeof(int));
		movl num_cols(%ebp), %eax # eax = num_cols
		shll $2, %eax # eax = num_cols * sizeof(int)
		push %eax # set the argument to malloc
		call malloc # eax = (int*)malloc( num_cols * sizeof(int))
		addl $1 *ws, %esp # clear malloc's argument
		movl C(%ebp), %edx # edx = C
		movl i(%ebp), %ecx # restore ecx back to i
		movl %eax, (%edx, %ecx, ws) # C[i] = (int*)malloc( num_cols * sizeof(int))

		# edi will be j
		movl $0, %edi # j = 0
		# for(j = 0; j < num_cols; ++j)
		inner_for_start:
			# j - num_cols < 0
			# neg: j - num_cols >= 0
			cmpl num_cols(%ebp), %edi # j - num_cols
			jge inner_for_end

			# C[i][j] = A[i][j] + B[i][j];
			# *(*(C + i) + j) = *(*(A + i) + j) + *(*(B + i) + j)

			# A[i][j] == *(*(A + i) + j)
			movl A(%ebp), %edx # edx = A
			movl (%edx, %ecx, ws), %edx # edx = A[i]
			movl (%edx, %edi, ws), %edx # edx = A[i][j]

			#B[i][j] ==  *(*(B + i) + j)
			movl B(%ebp), %esi # esi = B
			movl (%esi, %ecx, ws), %esi # esi = B[i]
			addl (%esi, %edi, ws), %edx # edx = A[i][j] + B[i][j]

			movl %edx, (%eax, %edi, ws) # C[i][j] = A[i][j] + B[i][j]
			

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

		movl %ebp, %esp # clear space for locals, args, and scratch 
		pop %ebp 
		ret 
	epilogue_end:


