#lang racket

;; literal text reader
;; exports template containing string content of a file with
;; #lang reader raw declared

(require syntax/strip-context)
 
(provide (rename-out [literal-read read]
                     [literal-read-syntax read-syntax]))
 
(define (literal-read in)
  (syntax->datum
   (literal-read-syntax #f in)))
 
(define (literal-read-syntax src in)
  (with-syntax ([str (port->string in)])
    (strip-context
     #'(module anything racket
         (provide raw)
         (define raw 'str)))))

