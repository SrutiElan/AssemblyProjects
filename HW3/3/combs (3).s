.text
.global get_combs

# External functions
.extern malloc
.extern num_combs

# get_combs(int* items, int k, int len)
get_combs:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    # Calculate number of combinations
    pushl 12(%ebp)    # k
    pushl 16(%ebp)    # len
    call num_combs
    addl $8, %esp

    # Save num_combs result
    movl %eax, %edi

    # Allocate array of pointers
    pushl %eax
    imull $4, %eax    # sizeof(int*)
    pushl %eax
    call malloc
    addl $4, %esp
    popl %ecx         # Restore num_combs
    movl %eax, %ebx   # Save result array pointer

    # Allocate each row
    xorl %esi, %esi   # Counter = 0
alloc_rows:
    cmpl %edi, %esi
    jge alloc_done

    # Allocate row memory
    pushl %esi
    movl 12(%ebp), %eax   # k
    imull $4, %eax        # sizeof(int)
    pushl %eax
    call malloc
    addl $4, %esp
    popl %esi

    # Store row pointer
    movl %eax, (%ebx,%esi,4)

    incl %esi
    jmp alloc_rows

alloc_done:
    # Setup recursive helper call
    pushl $0              # current_pos
    pushl $0              # current_index
    pushl %ebx            # result array
    pushl 16(%ebp)        # len
    pushl 12(%ebp)        # k
    pushl 8(%ebp)         # items
    call generate_combs
    addl $24, %esp

    movl %ebx, %eax      # Return result array

    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

# Recursive helper function
# Parameters: items, k, len, result, current_index, current_pos
generate_combs:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    # Check if we've selected k items
    movl 12(%ebp), %eax   # k
    cmpl %eax, 24(%ebp)   # current_pos
    je combination_done

    # Check if we've run out of items
    movl 16(%ebp), %eax   # len
    cmpl %eax, 20(%ebp)   # current_index
    jge return_early

    # Get current element
    movl 8(%ebp), %ebx    # items
    movl 20(%ebp), %esi   # current_index
    movl 24(%ebp), %edi   # current_pos
    movl (%ebx,%esi,4), %eax  # Get current item

    # Store in current combination
    movl 16(%ebp), %ebx   # result array
    movl 24(%ebp), %ecx   # current_pos
    movl %eax, (%ebx,%ecx,4)

    # Recursive call including current element
    movl 24(%ebp), %eax
    incl %eax
    pushl %eax            # current_pos + 1
    movl 20(%ebp), %eax
    incl %eax
    pushl %eax            # current_index + 1
    pushl 16(%ebp)        # result
    pushl 12(%ebp)        # len
    pushl 8(%ebp)         # k
    pushl 4(%ebp)         # items
    call generate_combs
    addl $24, %esp

    # Recursive call excluding current element
    pushl 24(%ebp)        # current_pos
    movl 20(%ebp), %eax
    incl %eax
    pushl %eax            # current_index + 1
    pushl 16(%ebp)        # result
    pushl 12(%ebp)        # len
    pushl 8(%ebp)         # k
    pushl 4(%ebp)         # items
    call generate_combs
    addl $24, %esp

combination_done:
return_early:
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret