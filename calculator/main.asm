.include "calculator.asm"

.section .data
prompt: .ascii "> "
msg_error_numerical_syntax_invalid: "Expected a number but didn't find a numerical value!", 0
msg_error_symbol_syntax_invalid: "Syntax error: Expected a symbol after number and a space after symbol", 0

.section .bss
.lcomm buffer, 1024

.section .text
.globl _start

_start:

    call calculator

    xor %ebx, %ebx
    jmp exit

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

        jmp .looper

    pop %edi
    pop %esi
    pop %ebx

    mov %ebp, %esp
    pop %ebp

    ret
