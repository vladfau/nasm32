section .data
    fmt: db "Hello world",10, 0

section .text
    extern printf
    global main
    main:
    push fmt
    call printf
    add esp, 4
    xor eax, eax
    xor ecx, ecx
    ret
