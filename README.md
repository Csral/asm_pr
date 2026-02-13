# Assembly Personal Repetitions

This repo contains assembly code that is used to test my skills and revise assembly at any instance of time. Watch me write programs that aren't meant to be written in assembly and bear witness to me tormenting myself over simple programs to master and be in touch with assembly.

In simpler terms, this is an educational repo for reference and fun.

## Torment Log
A file containing all sort of lessons that I learnt the hard way - from something laughably simple to sadistically complex.

### How to Run (Linux x86)
To assemble and link these masterpieces of masochism:

```bash
as --32 -o program.o program.s
ld -m elf_i386 -o program program.o
./program
```

**The stack is manually managed - so its chaotic. If its confusing to understand, make your own!**