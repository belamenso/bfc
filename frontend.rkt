#lang racket

(require "utils/stack.rkt")

(provide parse
         openingBracket
         closingBracket
         pointer-move
         value-update)

;; intermediate representation of parsed brainfuck code is
;; a list of elements: #\. #\, and the following

(struct openingBracket (n) #:transparent)
(struct closingBracket (n) #:transparent)
(struct pointer-move (n) #:transparent)
(struct value-update (n) #:transparent)

;; movePointer and updateValue serve as an abstraction over
;; brainfuck repetitive code, e.g. +++ becomes (value-update 3)
;; and <<<> becomes (pointer-move -2)

(define (parse program)
  (define parsed '())
  (define stack (make-stack))
  (define lastLabel 0)

  (define (sequence-squeezer constructor type? get positive?)
    (if (or
         (zero? (length parsed))
         (not (type? (car parsed))))
        (set! parsed (cons (constructor (if positive? 1 -1)) parsed))
        (set! parsed (cons (constructor ((if positive? add1 sub1) (get (car parsed)))) (cdr parsed)))))
  
  (for ([c (in-string program)])
    (match c
      [(or #\. #\,) (set! parsed (cons c parsed))]
      [#\+ (sequence-squeezer value-update value-update? value-update-n #t)]
      [#\- (sequence-squeezer value-update value-update? value-update-n #f)]
      [#\< (sequence-squeezer pointer-move pointer-move? pointer-move-n #f)]
      [#\> (sequence-squeezer pointer-move pointer-move? pointer-move-n #t)]
      [#\[ (set! parsed (cons (openingBracket lastLabel) parsed))
           (set! stack (stack-push stack lastLabel))
           (set! lastLabel (add1 lastLabel))]
      [#\] (let-values ([(top new-stack) (stack-pop stack)])
             (set! parsed (cons (closingBracket top) parsed))
             (set! stack new-stack))]
      [else (void)]))
  (reverse parsed))

