section .data
    fmtin: db "%d%d", 0
    fmtout: db "%d", 0, 10

section .bss
    a: resd 1
    b: resd 1
    s: resd 1

section .text
    extern _scanf
    extern _printf
    global _main
    _main:
    push b
    push a
    push fmtin
    call _scanf
    add esp, 12
    mov eax, [a]
    add eax, [b]
    mov [s], eax
    push dword [s]
    push fmtout
    call _printf
    add esp, 8
    xor eax, eax
    xor ecx, ecx
    ret
