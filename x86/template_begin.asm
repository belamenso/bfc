#lang reader "../utils/raw.rkt"
section .data

on: db "stty raw -echo",0
off: db "stty -raw echo; stty sane",0

section .bss

mem: resb 30000
; boolean flags, 1 if LF/CR was the last printed character
lastLF: resb 1
lastCR: resb 1

section .text

global main
extern getchar, putchar, system

printChar:
    push ebp 
    mov ebp, esp

    mov byte[lastLF], 0
    mov byte[lastCR], 0

    ; print \r as \n\r
    cmp byte[ecx], 13
    jne .checkLF
    mov byte[lastCR], 1
    push eax
    push ecx
    push 10
    call putchar
    add esp, 4
    pop ecx
    pop eax

.checkLF:
    cmp byte[ecx], 10
    jne .rest
    mov byte[lastLF], 1

.rest:
    push eax
    push ecx
    mov eax, 0
    mov al, byte[ecx]
    push eax
    call putchar
    add esp, 4

    pop ecx 
    pop eax 
    mov esp, ebp 
    pop ebp 
    ret

readChar:
    push ebp
    mov ebp, esp

    push eax
    push ecx
    call getchar
    pop ecx
    mov byte[ecx], al
    pop eax

    ; handle CTRL-D, CTRL-C
    cmp byte[ecx], 4
    je .exit
    cmp byte[ecx], 3
    jne .end
.exit:
    mov esp, ebp
    pop ebp
    jmp exit

.end:
    call printChar

    mov esp, ebp
    pop ebp
    ret

main:
    push ebp
    mov ebp, esp

    ; on
    push on
    call system
    add esp, 4

    ; init pc
    mov ecx, mem
    mov eax, 0

