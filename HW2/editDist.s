.global _start

.data


string1:
    .string "kitten"
string2:     
    .string "sitting"              # Reserve 101 bytes for string2 (uninitialized)
oldDist:     
    .space 404            # Reserve 101 bytes for oldDist (uninitialized)
curDist:     
    .space 404    
	
word1_len: 
    .long 0

word2_len:
    .long 0

i:
    .long 0

j: 
    .long 1

.text
# min (int a, int b), parameters in %eax and %ebx
min:
    cmpl %ebx, %eax  # eax < ebx
    jle min_end # eax - ebx <= 0, then eax is min
    movl %ebx, %eax 

min_end:
    ret

swap: 
    # Function: swap(int** a, int** b)
    # %eax = address of oldDist (pointer to a)
    # %ebx = address of curDist (pointer to b)
    
    movl (%eax), %ecx      # Load *a (oldDist address) into %ecx
    movl (%ebx), %edx      # Load *b (curDist address) into %edx
    
    movl %edx, (%eax)      # *a = *b (store curDist address into oldDist)
    movl %ecx, (%ebx)      # *b = *a (store oldDist address into curDist)

    ret                    # Return to the caller

strlen_reg:
    # str should be passed through %eax
	# return value will be in %edx
    # count will be %ebx
    # caller saved reg

    # int count= 0; 
	movl $0, %ebx 

    # while (str[count] != '\0')
    strlen_reg_while_start:
        # str[count] - '\0' != 0
        # negation: str[count] - '\0' == 0
        # *(str + count )
        cmpb $0, (%eax, %ebx, 1) # str[count] - '\0'
        je strlen_reg_while_end
        incl %ebx # count++ 
        jmp strlen_reg_while_start
    strlen_reg_while_end:
    movl %ebx, %edx # set the return value
    ret

_start:
	# lengths of string1 and string 2
    movl $string1, %eax # string 1 is in eax
    call strlen_reg # returns count in edx
    movl %edx, word1_len # word1_len = edx
	
    movl $string2, %eax # string 2 is in eax
    call strlen_reg # returns count in edx
    movl %edx, word2_len # word2_len = edx

    /**
    i is in ecx
    word2_len + 1 is in eax
     */
    
    #  for(i = 0; i < word2_len + 1; i++){
    # i is ecx
    mov $0, %ecx  # i = 0
    movl word2_len, %eax # eax = word2_len
    incl %eax # eax = word2_len + 1

    for1_start:
        # if (i >= word2_len + 1) break
        # i - word2_len+1 >= 0
        cmpl %eax, %ecx # i - word2_len+1
        jge for1_end

        movl %ecx, oldDist(,%ecx, 4) # oldDist[i] = i
        movl %ecx, curDist(,%ecx, 4) # curDist[i] = i;


        incl %ecx #++i
        jmp for1_start
    for1_end:

    # main loop through string1 chracteres

    movl word1_len, %ebx # ebx = word1_len
    incl %ebx # ebx = word1_len + 1
    movl $1, %ecx # i = 1
    /**
    word2_len + 1 is in eax but can use 
    word1_len + 1 is in ebx but can use
    i is in ecx
    j is in edx
    i-1 is in esi
    j-1 is in edi
    string1(i-1) is in al
    string2(j-1) is in cl
     */
    
    # for(i = 1; i < word1_len + 1; i++){
main_loop:
    movl %ecx, i # i = ecx 

    /**can use eax and ebx past the ---- line */
    # redefining EBX
    movl word1_len, %ebx # ebx = word1_len
    incl %ebx # ebx = word1_len + 1

    # if (i >= word1_len+1 )  break
    # i - word1_len+1 >= 0
    cmpl %ebx, %ecx 
    jge main_done
    #--------------------
    movl %ecx, curDist # curDist[0] = i;

    movl $1, %edx # edx = 1
    movl %edx, j # j = edx
        inner_loop:
        # redefining EAX word2_len+1 
        movl word2_len, %eax # eax = word2_len
        incl %eax # eax = word2_len + 1

        # for(j = 1; j < word2_len + 1; j++){
        # if (j >= word2_len+1 )  break
        # j - word2_len+1 >= 0
        cmpl %eax, %edx # comp word2_len+1 and j
        jge inner_done
        #--------------------
            # if(word1[i-1] == word2[j-1]){
            movl %ecx, %esi       # esi = ecx = i
            dec %esi              # esi = i - 1
            movl %edx, %edi       # edi = edx = j
            dec %edi              # edi = j - 1
            movb string1(%esi), %al  # Load character at word1[i-1] into lower byte of %eax
            movb string2(%edi), %bl  # Load character at word2[j-1] into lower byte of %ebx
            cmpb %al, %bl            # Compare characters
            jne different_chars      # Jump if characters are different

# Characters are the same
movl oldDist(,%edi, 4), %eax # Load oldDist[j-1]
movl %eax, curDist(,%edx, 4) # Set curDist[j] = oldDist[j-1]
jmp update_inner
            
            different_chars:
            /** 
            curDist[j] = min(min(oldDist[j], //deletion
                          curDist[j-1]), //insertion
                          oldDist[j-1]) + 1;
            **/
            # min(oldDist[j], curDist[j-1])
            movl oldDist(,%edx, 4), %eax # eax: oldDist[j]
            movl curDist(,%edi, 4), %ebx  # ebx : curDist[j-1]
            call min # answer wil be in eax
            # min(prev min , oldDist[j-1] )
            movl oldDist(,%edi, 4), %ebx # ebx: oldDist[j-1]
            call min # answer wil be in eax

            incl %eax # eax += 1
            movl %edx, j # j = edx

            movl %eax, curDist(,%edx, 4) # curDist[j] = result

        update_inner:
        incl %edx # j++
        
        jmp inner_loop
        inner_done:

    # swap(&oldDist, &curDist);
    lea oldDist, %eax   # Load address of oldDist into %eax
    lea curDist, %ebx   # Load address of curDist into %ebx
    call swap           # Call the swap function to swap the pointers


    movl i, %ecx # revive i's value %ecx = i
    incl %ecx # i++
    jmp main_loop

main_done:
    movl word2_len, %ebx  # ebx = word2_len
    # store result in %eax
    movl oldDist(,%ebx, 4), %eax 


done:
    nop
