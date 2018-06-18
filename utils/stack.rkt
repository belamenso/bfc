#lang racket

;; simple stack implementation

(provide make-stack
         stack-pop
         stack-push)

(define (make-stack) '())
(define (stack-pop stack) (values (car stack) (cdr stack)))
(define (stack-push stack val) (cons val stack))