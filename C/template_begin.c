#lang reader "../utils/raw.rkt"
#include <stdio.h>
#include <stdlib.h>

char *memory, *ptr;
char lastPrintedLF, lastPrintedCR;

void print_char() {
    lastPrintedCR = lastPrintedLF = 0;
    if (*ptr == '\r') {
        putchar('\n');
        lastPrintedCR = 1;
    }
    if (*ptr == '\n') lastPrintedLF = 1;
    putchar(*ptr);
}

void read_char() {
    *ptr =  getchar();
    if (3 <= *ptr && *ptr <= 4) // ^C, ^D
        exit(0);
    print_char();
}

int main() {
    memory = (char*)calloc(30000, sizeof(char));
    ptr = memory;

    system("stty raw -echo");

