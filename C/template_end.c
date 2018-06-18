#lang reader "../utils/raw.rkt"
    system("stty -raw echo; stty sane");
    if (!lastPrintedCR) {
        if (!lastPrintedLF) putchar('\n');
        putchar('\r');
    }
    free(memory);
    return 0;
}
