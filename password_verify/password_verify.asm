#   Collect INput.
#   Check for 1 Cap, 1 Small, 1 Number
#   Print/loop based on that

.section .data
msg: .ascii "Hello There> "
invalid_pass: .ascii "Invalid password: Must have 1 of small and capital alphabets and a number.\n"
valid_pass: .ascii "Password validated.\n"

.section .bss
.lcomm buffer, 100

.section .text
.globl _start

_start:

    push $100
    push $buffer

    push $13
    push $msg

    call scanf
    add $16, %esp

    push %eax
    push $buffer

    call verifyPassword
    add $8, %esp

    cmp $1, %eax
    je _start

    mov $1, %eax
    xor %ebx, %ebx

    int $0x80

.type verifyPassword, @function
verifyPassword:

    # vp(char* password, size_t size)

    push %ebx
    push %esi
    push %edi
    push %ebp

    mov %esp, %ebp
    sub $12, %esp # local vars
    # stack (top - end ): num(-12), small(-8), cap(-4)

    movl $0, -4(%ebp)   # Clear Caps counter
    movl $0, -8(%ebp)   # Clear Small counter
    movl $0, -12(%ebp)  # Clear Num counter

    mov 20(%ebp), %ebx # string
    mov 24(%ebp), %ecx

    xor %edi, %edi

    looper:

        cmp %ecx, %edi
        jge end_verify

        movzbl (%ebx, %edi, 1), %eax 
        # Loads byte, fills rest of %eax with 0s
        inc %edi

        cmp $65, %eax
        jge VERIFY_CAPITAL

        continue_small:
        
        cmp $97, %eax
        jge VERIFY_SMALL

        continue_num:

        cmp $48, %eax
        jge VERIFY_NUM

        # Some other character
        jmp looper

        VERIFY_CAPITAL:

            cmp $90, %eax
            jle IS_CAPITAL

            jmp continue_small

            IS_CAPITAL:

                addl $1, -4(%ebp)
                jmp looper

        VERIFY_SMALL:

            cmp $122, %eax
            jle IS_SMALL

            jmp continue_num

            IS_SMALL:

                addl $1, -8(%ebp)
                jmp looper

        VERIFY_NUM:

            cmp $57, %eax
            jg looper

            # it is a number
            addl $1, -12(%ebp)
            jmp looper

        end_verify:

            # valid if all 3 local vars are > 1.
            mov -4(%ebp), %edx
            cmp $0, %edx
            jle INVALID_PASS

            mov -8(%ebp), %edx
            cmp $0, %edx
            jle INVALID_PASS

            mov -12(%ebp), %edx
            cmp $0, %edx
            jle INVALID_PASS

            jmp VALID_PASS

            INVALID_PASS:

                push $75
                push $invalid_pass

                call print
                add $8, %esp

                mov $1, %eax # report failure.
                jmp end_fn_verify

            VALID_PASS:

                push $20
                push $valid_pass

                call print
                add $8, %esp

                mov $0, %eax # report success
                jmp end_fn_verify

    end_fn_verify:
    mov %ebp, %esp

    pop %ebp
    pop %edi
    pop %esi
    pop %ebx

    ret

.type scanf, @function
scanf:

    # scanf(char* prompt, size_t p_size, char* buffer, size_t size)

    push %ebx
    push %esi
    push %edi
    push %ebp

    mov %esp, %ebp

    mov 24(%ebp), %ebx
    push %ebx
    mov 20(%ebp), %ebx
    push %ebx

    call print
    add $8, %esp

    mov $3, %eax
    xor %ebx, %ebx

    mov 28(%ebp), %ecx
    mov 32(%ebp), %edx

    int $0x80

    mov %ebp, %esp

    pop %ebp
    pop %edi
    pop %esi
    pop %ebx

    ret

.type print, @function
print:

    # print(char* msg, size_t size)

    push %ebx
    push %esi
    push %edi
    push %ebp

    mov %esp, %ebp

    mov $4, %eax
    mov $1, %ebx
    
    mov 20(%ebp), %ecx
    mov 24(%ebp), %edx

    int $0x80

    mov %ebp, %esp

    pop %ebp
    pop %edi
    pop %esi
    pop %ebx

    ret
