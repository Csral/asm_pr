.type parse_calc ,@function
parse_calc:

    # parse_calc(char* data, size_t size)

    push %ebp
    mov %esp, %ebp

    push 12(%ebp)
    push 8(%ebp)

    # we need 2 local variables - num1, num2.
    # Each operation updates num1, we fetch num2 after a symbol.

    # As planned, repeatedly validate a syntax.
    call obtain_numerical
    jc .error_numerical_syntax_invalid



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

# Idea: Parse each line character by character. Every space ends the previous token.
# Keep track of the entire thing. Maximum of 1024 entries. However, since space is delimiter and buffer size is 1024,
# Ideally we cannot exceed 1 char and 1 space combo = 512 Entries.
# Supports: Numbers, +, -, *, /, %

.type obtain_numerical, @function
obtain_numerical:

    # int obtain_numerical(char* data, size_t size)

    push %ebp
    mov %esp, %ebp
    push %ebx
    push %edx
    push %esi
    push %edi

    xor %eax, %eax
    # local variable for numerical value.
    sub $4, %esp
    mov %eax, -20(%ebp)

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
        mov -20(%ebp), %eax

        # eax = (eax * 10) + ebx
        imul $10, %eax
        add %ebx, %eax

        mov %eax, -20(%ebp)
        inc %edi

        # load length
        mov 12(%ebp), %edx

        cmp %edi, %edx
        jg .looper
        jmp .end

    .error_num_obt:
        stc

    .end:

        # load the return value
        mov -20(%ebp), %eax
        # clear stack.
        add $4, %esp

        pop %edi
        pop %esi
        pop %edx
        pop %ebx
        mov %ebp, %esp
        pop %ebp

        ret
