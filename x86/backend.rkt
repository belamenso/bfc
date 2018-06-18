#lang racket

(require "../frontend.rkt"
         (prefix-in nasm-begin. "template_begin.asm")
         (prefix-in nasm-end. "template_end.asm"))

(provide generate-asm
         compile-parsed
         write-asm-file
         compile-asm-file
         delete-asm-file
         delete-object-file
         delete-immediate-files)

;; functions generating Intel x86 NASM code from IR tokens

(define (generate-value-update n s)
  (when ((not/c zero?) n)
    (fprintf s "\tmov al, byte[ecx]\n")
    (if (positive? n)
        (fprintf s "\tadd al, ~v\n" n)
        (fprintf s "\tsub al, ~v\n" (abs n)))
    (fprintf s "\tmov byte[ecx], al\n")))

(define (generate-print s)
  (display "\tcall printChar\n" s))

(define (generate-read s)
  (display "\tcall readChar\n" s))

(define (generate-pointer-move n s)
  (when ((not/c zero?) n)
    (if (positive? n)
        (fprintf s "\tadd ecx, ~v\n" n)
        (fprintf s "\tsub ecx, ~v\n" (abs n)))))

(define (generate-open-bracket n s)
  (fprintf s "opening_~v:
    mov al, byte[ecx]
    test al, al
    jz closing_~v\n" n n))

(define (generate-close-bracket n s)
  (fprintf s"\tmov al, byte[ecx]
    test al, al
    jnz opening_~v
closing_~v:\n" n n))

;; IR -> String
;; complete Intel x86 NASM assembly program
(define (generate-asm parsed)
  (define s (open-output-string))
  (display nasm-begin.raw s)
  (for ([token (in-list parsed)])
    (match token
      [(pointer-move n) (generate-pointer-move n s)]
      [(value-update n) (generate-value-update n s)]
      [#\. (generate-print s)]
      [#\, (generate-read s)]
      [(openingBracket n) (generate-open-bracket n s)]
      [(closingBracket n) (generate-close-bracket n s)]
      [else (void)]))
  (display nasm-end.raw s)
  (get-output-string s))

;; IR -> String -> Bool
(define (compile-parsed parsed file-name)
  (and (write-asm-file parsed file-name)
       (compile-asm-file file-name)))

;; IR -> String -> Bool
;; writes FILE.nasm
(define (write-asm-file parsed file-name)
  (with-handlers ([exn:fail? (λ (e) #f)])
    (call-with-output-file (string-append file-name ".asm")
      #:exists 'replace
      (λ (f) (display (generate-asm parsed) f)))))

;; String -> Bool
;; assumes file-name.asm exists, writes file-name.o
;; writes file-name
(define (compile-asm-file file-name)
  (let* ([immediate-name (string-append file-name ".o")]
         [write-object-file
          (string-append "nasm -f elf " file-name ".asm -o " immediate-name)]
         [link-object-file
          (string-append "gcc -m32 " immediate-name " -o " file-name)])
    (and (system write-object-file)
         (system link-object-file))))

;; String -> Bool
;; deletes .asm file
(define (delete-asm-file file-name)
  (with-handlers ([exn:fail? (λ (e) #f)])
    (delete-file (string-append file-name ".asm"))))

;; String -> Bool
;; deletes .o file
(define (delete-object-file file-name)
  (with-handlers ([exn:fail? (λ (e) #f)])
    (delete-file (string-append file-name ".o"))))

;; String -> Bool
;; deletes .asm and .o files
(define (delete-immediate-files file-name)
  (with-handlers ([exn:fail? (λ (e) #f)])
    (delete-file (string-append file-name ".o"))
    (delete-file (string-append file-name ".asm"))))

