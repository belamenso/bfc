#lang reader "../utils/raw.rkt"
exit:
    ; off
    push off 
    call system
    add esp, 4

    ; print \n\r to repair display
    cmp byte[lastCR], 1 ; if last printed \r, done
    je .donePrinting
    cmp byte[lastLF], 1 ; if last printed \n, print \r
    je .printCR
    ; else, print \n\r
.printLF:
    push 10
    call putchar
    add esp, 4
.printCR:
    push 13
    call putchar
    add esp, 4
.donePrinting:

    mov esp, ebp
    pop ebp
    mov eax, 0
    ret

