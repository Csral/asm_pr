.type parse_calc ,@function
parse_calc:

    # parse_calc(char* data, size_t size)

    push %ebp
    mov %esp, %ebp

    push 12(%ebp)
    push 8(%ebp)

    call print

    mov %ebp, %esp
    pop %ebp

    ret

# Idea: Parse each line character by character. Every space ends the previous token.
# Keep track of the entire thing. Maximum of 1024 entries. However, since space is delimiter and buffer size is 1024,
# Ideally we cannot exceed 1 char and 1 space combo = 512 Entries.
# Supports: Numbers, +, -, *, /, %


