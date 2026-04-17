.include "calculator.asm"

.section .data
prompt: .ascii "> "
msg_print_result: .ascii "= "
msg_nl: .ascii "\n"
powers_of_ten: .long 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000
msg_error_numerical_syntax_invalid: .ascii "Expected a number but didn't find a numerical value!", 0
msg_error_symbol_syntax_invalid: .ascii "Syntax error: Expected a symbol after number and a space after symbol", 0

.section .bss
.lcomm buffer, 1024
.lcomm res_buffer, 100

.section .text
.globl _start

_start:

    call calculator

    xor %ebx, %ebx
    jmp exit

.type pow10, @function
pow10:

    # pow10(int exp)

    # exponent of 10 function.
    push %ebp
    mov %esp, %ebp
    push %edi

    # Lets just make it fixed so we can make it very quick!
    mov 8(%ebp), %edi
    # Negative numbers aren't handled as its an internal function and I don't intend to send -ve nums
    cmp $9, %edi
    jge .higher

    mov powers_of_ten(,%edi, 4), %eax
    jmp .end

    .higher:
        stc
        mov $9, %edi
        mov powers_of_ten(,%edi, 4), %eax
        jmp .end

    .end:
        pop %edi
        mov %ebp, %esp
        pop %ebp

        ret

.type print_result, @function
print_result:

    # print_result(int result)
    push %ebp
    mov %esp, %ebp

    mov 8(%ebp), %eax
    xor %edx, %edx
    mov $10, %ebx

    xor %edi, %edi
    mov $res_buffer, %esi

    .looper:

        idiv %ebx
        inc %edi
        xor %edx, %edx
        test %eax, %eax
        jnz .looper

        mov 8(%ebp), %eax
        # IMP: ecx must not be overwritten in convert!
        mov %edi, %ecx
        jmp .convert

    .convert:

        push %eax
        
        push %edi
        call pow10
        mov %eax, %ebx
        dec %edi

        pop %eax

        idiv %ebx
        add $48, %eax
        movzbl %eax, (%esi)
        inc %esi
        mov %edx, %eax
        xor %edx, %edx

        test %edi, %edi
        jge .convert

        jmp .finish

    .finish:

        push %ecx
        push $res_buffer

        call print
        add $8, %esp

        mov $1, %ecx
        push %ecx
        push $msg_nl

        call print
        add $8, %esp

    mov %ebp, %esp
    pop %ebp

    ret

.type scanf, @function
scanf:

    # scanf(char* msg, size_t m_size, char* buffer, size_t size)

    push %ebp
    mov %esp, %ebp

    push %ebx

    push 12(%ebp)
    push 8(%ebp)
    call print
    add $8, %esp

    mov $3, %eax
    xor %ebx, %ebx

    mov 16(%ebp), %ecx
    mov 20(%ebp), %edx

    int $0x80

    pop %ebx

    mov %ebp, %esp
    pop %ebp

    ret

.type print, @function
print:

    # print(char* msg, size_t size)

    push %ebp
    mov %esp, %ebp

    push %ebx # -4

    mov $4, %eax
    mov $1, %ebx

    mov 8(%ebp), %ecx
    mov 12(%ebp), %edx

    int $0x80

    pop %ebx

    mov %ebp, %esp
    pop %ebp

    ret

exit:

    # exit(int code) - passed to ebx
    # jmp here

    mov $1, %eax

    int $0x80

.type calculator, @function
calculator:

    push %ebp
    mov %esp, %ebp

    push %ebx # -4
    push %esi # -8
    push %edi # -12

    .looper:

        push $1024
        push $buffer
        push $2
        push $prompt

        call scanf
        add $16, %esp

        push %eax
        push $buffer
        call parse_calc
        add $8, %esp

        push $1
        push $msg_nl
        call print
        add $8, %esp

        jmp .looper

    pop %edi
    pop %esi
    pop %ebx

    mov %ebp, %esp
    pop %ebp

    ret
