; echos lines until "quit"
; "kill" unloads server
; runs on loopback, 127.0.0.1, and port 2002,
; nasm -f elf httpd.asm
; ld -m elf_i386 -o httpd httpd.o

global _start

struc sockaddr_in
    .sin_family resw 1
    .sin_port resw 1
    .sin_addr resd 1
    .sin_zero resb 8
endstruc

; Convert numbers (constants!) to network byte order
%define hton(x) ((x & 0xFF000000) >> 24) | ((x & 0x00FF0000) >>  8) | ((x & 0x0000FF00) <<  8) | ((x & 0x000000FF) << 24)
%define htons(x) ((x >> 8) & 0xFF) | ((x & 0xFF) << 8)

AF_INET        equ 2
SOCK_STREAM    equ 1
INADDR_ANY	equ 0	; /usr/include/linux/in.h

STDIN          equ 0
STDOUT         equ 1

__NR_exit	equ 1
__NR_read       equ 3
__NR_write      equ 4
__NR_close	equ 6
__NR_socketcall equ 102

; /usr/include/linux/in.h
SYS_SOCKET	equ 1
SYS_BIND	equ 2
SYS_CONNECT	equ 3
SYS_LISTEN	equ 4
SYS_ACCEPT	equ 5
SYS_SEND	equ 9
SYS_RECV	equ 10
;------------------------

_ip equ 0x7F000001		; loopback - 127.0.0.1
_port equ 2002

; Convert 'em to network byte order
IP equ hton(_ip)
PORT equ htons(_port)

BACKLOG		equ 128	; for "listen"
BUFLEN         equ  1000

section .data

    my_sa istruc sockaddr_in
        at sockaddr_in.sin_family, dw AF_INET
        at sockaddr_in.sin_port, dw PORT
        at sockaddr_in.sin_addr, dd INADDR_ANY
        at sockaddr_in.sin_zero, dd 0, 0
    iend

    socket_args dd AF_INET, SOCK_STREAM, 0

    bind_args   dd 0, my_sa, sockaddr_in_size
    listen_args dd 0, BACKLOG
    accept_args dd 0, 0, 0

section .bss
        my_buf resb BUFLEN
        fd_socket resd 1
        fd_conn resd 1

section .text
     _start:

        ; create socket file descriptor
        ; socket(AF_INET, SOCK_STREAM, 0)
        mov ecx, socket_args	; address of args structure
        mov ebx, SYS_SOCKET
        mov eax, __NR_socketcall     ; /usr/src/linux/net/socket.c
        int 80h ; return fd_socket: file descriptor socket address to eax

        cmp eax, -4096 ; if something wrong
        ja exit

        mov [fd_socket], eax
        ; and fill in bind_args, etc.
        mov [bind_args], eax
        mov [listen_args], eax
        mov [accept_args], eax


        mov ecx, bind_args
        mov ebx, SYS_BIND ; bind to selected socket
        mov eax, __NR_socketcall
        int 80h

        cmp eax, -4096
        ja exit

        mov ecx, listen_args
        mov ebx, SYS_LISTEN	; start listening
        mov eax, __NR_socketcall
        int 80h

        cmp eax, -4096
        ja exit

    again:
        mov ecx, accept_args
        mov ebx, SYS_ACCEPT	; accept incoming
        mov eax, __NR_socketcall
        int 80h
        cmp eax, -4096
        ja  exit

        mov [fd_conn], eax ; where to read from, descriptor address
    readagain:
        ; read(sock, buf, len)
        mov edx, BUFLEN		; arg 3: size of buffer
        mov ecx, my_buf		; arg 2: buffer
        mov ebx, [fd_conn]	; arg 1: descriptor address
        mov eax, __NR_read	; call reading
        int 80h

        cmp eax, -4096
        ja exit

        mov edx, eax		; length read is length to write
        mov ecx, my_buf     ; what to write
        mov ebx, [fd_conn]  ; where to write
        mov eax, __NR_write ; call write
        int 80h
        cmp eax, -4096
        ja exit

        cmp dword [my_buf], 'quit' ; if quit - then closde connection
        jz closeconn ; like strcmp()

        cmp dword [my_buf], 'kill' ; close both connection and socket
        jz killserver

        jmp readagain
    closeconn:
        mov eax, __NR_close ; close connection
        mov ebx, [fd_conn]
        int 80h
        cmp eax, -4096
        ja exit
        jmp again
    killserver:
        mov eax, __NR_close ; close connection
        mov ebx, [fd_conn]
        int 80h
        mov eax, __NR_close ; close socket
        mov ebx, [fd_socket]
        int 80h
    exit:
        mov ebx, eax		; exitcode
        neg ebx
        mov eax, __NR_exit
        int 80h
