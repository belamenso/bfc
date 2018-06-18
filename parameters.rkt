#lang racket

(provide (all-defined-out))

(define in-file (make-parameter #f))
(define out-file (make-parameter #f))
(define only-asm? (make-parameter #f))
(define target (make-parameter "x86"))
(define cell-size (make-parameter 8))
(define tape-length (make-parameter 30000))