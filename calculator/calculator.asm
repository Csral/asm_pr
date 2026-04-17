.type parse_calc ,@function
parse_calc:

    # ! IMPORTANT personal note: Okay, this function can be optimized, I realize it as I am writing but yk what, lets do it at end.
    #                            let it be unoptimized for now - but get back to it. Memory, operations and speed all included!!

    # parse_calc(char* data, size_t size)

    push %ebp
    mov %esp, %ebp
    push %edx
    push %esi
    push %edi
    push %ebx

    # local variable to keep track of current offset
    xor %edi, %edi
    sub $4, %esp
    mov %edi, -20(%ebp)

    push 12(%ebp)
    push 8(%ebp)
    # As planned, repeatedly validate a syntax.
    call obtain_numerical
    jc .error_numerical_syntax_invalid
    add $8, %esp
    
    # note: Instead of passing offset, add offset of string to base after every call.
    # add ebx to index before calling the next function
    # now loop: obtain symbol, obtain number, eval.

    # store first number in eax, second in ebx. operator in ecx.
    mov -20(%ebp), %edi
    add %ebx, %edi
    mov %edi, -20(%ebp)
    
    mov 12(%ebp), %edx
    cmp %edx, %edi
    jge .end

    # more data exists.
    .looper:
        # store 1st number
        push %eax
        mov 8(%ebp), %esi
        add %edi, %esi
        sub %edi, %edx

        push %edx
        push %esi

        call obtain_symbol
        jc .error_symbol_syntax_invalid
        add $8, %esp

        mov %eax, %ecx
        pop %eax

        add $2, %edi
        mov %edi, -20(%ebp)

        mov 12(%ebp), %edx
        cmp %edx, %edi
        jge .error_numerical_syntax_invalid

        add %edi, %esi
        sub %edi, %edx

        # Save required registers
        push %eax
        push %ecx

        push %edx
        push %esi
        
        call obtain_numerical
        jc .error_numerical_syntax_invalid
        add $8, %esp

        add %ebx, %edi
        mov %edi, -20(%ebp)
        mov %eax, %ebx

        pop %ecx
        pop %eax
        
        # all required values exist, now to call the required operation.

        cmp $1, %ecx
        je .add_op

        cmp $2, %ecx
        je .sub_op

        cmp $3, %ecx
        je .mul_op

        cmp $4, %ecx
        je .div_op

        cmp $5, %ecx
        je .mod_op

        jmp err_no_op

        .add_op:
        add %ebx, %eax
        jmp .looper_condition

        .sub_op:
        sub %eax, %ebx
        mov %ebx, %eax
        jmp .looper_condition

        .mul_op:
        imul %ebx, %eax
        jmp .looper_condition

        .div_op:
        xor %edx, %edx
        idiv %ebx
        jmp .looper_condition

        .mod_op:
        xor %edx, %edx
        idiv %ebx
        mov %edx, %eax
        jmp .looper_condition

        .looper_condition:
            # eax will have result (first number is loaded!)
            xor %ecx, %ecx

            mov 12(%ebp), %edx
            mov -20(%ebp), %edi

            cmp %edx, %edi
            jl .looper

            # finished
            jmp .end

    .end:

        # use print_result and finish

        pop %ebx
        pop %edi
        pop %esi
        pop %edx
        mov %ebp, %esp
        pop %ebp

        ret

    .error_numerical_syntax_invalid:
        mov $52, %ecx
        mov msg_error_numerical_syntax_invalid, %edx

        push %ecx
        push %edx

        call print

        mov $1, %ebx
        jmp exit

    .error_symbol_syntax_invalid:
        mov $70, %ecx
        mov msg_error_symbol_syntax_invalid

        push %ecx
        push %edx
        call print

        mov $1, %ebx
        jmp exit

# Idea: Parse each line character by character. Every space ends the previous token.
# Keep track of the entire thing. Maximum of 1024 entries. However, since space is delimiter and buffer size is 1024,
# Ideally we cannot exceed 1 char and 1 space combo = 512 Entries.
# Supports: Numbers, +, -, *, /, %

.type obtain_symbol, @function
obtain_symbol:
    # int obtain_numerical(char* data, size_t size)
    # returns: 1 for +, 2 for - and so on till 5 for % in order of +,-,*,/,%

    clc

    push %ebp
    mov %esp, %ebp
    push %esi
    push %edi
    push %edx

    mov -12(%ebp), %esi
    mov $1, %edi
    # valid symbol is one of: +, -, *, /, %
    movzbl (%esi, %edi, 1), %eax
    inc %edi

    mov 12(%ebp), %edx
    sub $1, %edx

    cmp $0, %edx
    jle .err_invalid_statement

    cmp $43, %eax
    je .add_ret

    cmp $45, %eax
    je .sub_ret

    cmp $42, %eax
    je .mult_ret

    cmp $47, %eax
    je .div_ret

    cmp $37, %eax
    je .mod_ret

    jmp .err_invalid_statement

    # check if next entry is a space
    .add_ret:
    movzbl (%esi, %edi, 1), %eax
    cmp $32, %eax
    jne .err_invalid_statement

    mov $5, %eax
    jmp .end

    .sub_ret:
    movzbl (%esi, %edi, 1), %eax
    cmp $32, %eax
    jne .err_invalid_statement

    mov $5, %eax
    jmp .end

    .mult_ret:
    movzbl (%esi, %edi, 1), %eax
    cmp $32, %eax
    jne .err_invalid_statement
    
    mov $5, %eax
    jmp .end

    .div_ret:
    movzbl (%esi, %edi, 1), %eax
    cmp $32, %eax
    jne .err_invalid_statement

    mov $5, %eax
    jmp .end
    
    .mod_ret:
    movzbl (%esi, %edi, 1), %eax
    cmp $32, %eax
    jne .err_invalid_statement

    mov $5, %eax
    jmp .end

    .err_invalid_statement:
        stc
        xor %eax, %eax
        jmp .end

    .end:
        pop %edx
        pop %edi
        pop %esi
        mov %ebp, %esp
        pop %ebp

        ret

.type obtain_numerical, @function
obtain_numerical:

    # int obtain_numerical(char* data, size_t size)
    # allow this to take a begin parameter.
    # also return number of bytes read (in ebx) along with numerical value.

    push %ebp
    mov %esp, %ebp
    push %edx
    push %esi
    push %edi

    xor %eax, %eax
    xor %ebx, %ebx
    # local variable for numerical value and num bytes read.
    sub $8, %esp
    mov %eax, -16(%ebp)
    mov %ebx, -20(%ebp)

    # Keep reading the string until we encounter a space
    # load string
    mov 8(%ebp), %esi
    # load index
    xor %edi, %edi

    .looper:

        # loop until end of string or a space.
        # validate ASCII range for numbers.

        # load the character
        movzbl (%esi, %edi, 1), %ebx
        mov %ebx, %eax

        # get out if space
        cmp $32, %eax
        je .end

        # REFER: thoughts.md - section Range Computation
        xor %ecx, %ecx
        xor %edx, %edx

        sub $48, %eax
        sets %cl

        sub $10, %eax
        setns %dl

        or %cl, %dl
        test %dl, %dl
        jnz .error_num_obt

        # Convert to integer.
        sub $48, %ebx

        # we are working with a number!!!
        # load stored value into eax
        mov -16(%ebp), %eax

        # eax = (eax * 10) + ebx
        imul $10, %eax
        add %ebx, %eax

        mov %eax, -16(%ebp)
        inc %edi
        
        # load num_bytes_read
        mov -20(%ebp), %ebx
        inc %ebx
        mov %ebx, -20(%ebp)

        # load length
        mov 12(%ebp), %edx

        cmp %edi, %edx
        jg .looper
        jmp .end

    .error_num_obt:
        stc

    .end:

        # load the return values
        mov -16(%ebp), %eax
        mov -20(%ebp), %ebx
        # clear stack.
        add $8, %esp

        pop %edi
        pop %esi
        pop %edx
        mov %ebp, %esp
        pop %ebp

        ret
