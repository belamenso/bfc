#lang racket

(require "../frontend.rkt"
         (prefix-in c-begin. "template_begin.c")
         (prefix-in c-end. "template_end.c"))

(provide generate-c
         write-c-file)

;;

(define (generate-value-update n s)
  (when ((not/c zero?) n)
    (fprintf s "    *ptr += ~v;\n" n)))

(define (generate-print s)
  (display "    print_char();\n" s))

(define (generate-read s)
  (display "    read_char();\n" s))

(define (generate-pointer-move n s)
  (when ((not/c zero?) n)
    (fprintf s "    ptr += ~v;\n" n)))

(define (generate-open-bracket n s)
  (fprintf s "    while (*ptr) {\n"))

(define (generate-close-bracket n s)
  (fprintf s "    }\n"))

;;

;; IR -> String
;; complete C program
(define (generate-c parsed)
  (define s (open-output-string))
  (display c-begin.raw s)
  (for ([token (in-list parsed)])
    (match token
      [(pointer-move n) (generate-pointer-move n s)]
      [(value-update n) (generate-value-update n s)]
      [#\. (generate-print s)]
      [#\, (generate-read s)]
      [(openingBracket n) (generate-open-bracket n s)]
      [(closingBracket n) (generate-close-bracket n s)]
      [else (void)]))
  (display c-end.raw s)
  (get-output-string s))

;; IR -> String -> Bool
;; writes FILE.c
(define (write-c-file parsed file-name)
  (with-handlers ([exn:fail? (λ (e) #f)])
    (call-with-output-file (string-append file-name ".c")
      #:exists 'replace
      (λ (f) (display (generate-c parsed) f)))))
  

