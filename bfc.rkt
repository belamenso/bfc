#lang racket

(require "./frontend.rkt"
         "./x86/backend.rkt"
         "./C/backend.rkt")

(define in-file (make-parameter #f))
(define out-file (make-parameter #f))
(define only-asm? (make-parameter #f))
(define target (make-parameter "x86"))

(define (run-safe test error-msg)
  (when (not test)
    (displayln (string-append "bfc: " error-msg) (current-error-port))
    (exit 1)))

;; handle command line interface
(command-line
 #:program "bfc"
 #:once-each
 [("--output" "-o")
  OUT_FILE
  "Write output to FILE"
  (out-file OUT_FILE)]
 [("--asm" "-S")
  "Only generate assembly file (only for x86 target)"
  (only-asm? #t)]
 [("--target" "-t")
  TARGET
  "Set compilation target to TARGET (available: x86, C). Default target: x86"
  (match (string-downcase TARGET)
    ["c" (target "c")]
    ["x86" (target "x86")]
    [else (run-safe #f "Incorrect target (available: x86, C)")])]
 #:args (FILE)
 (if (and (regexp-match #rx".+\\.bf$" FILE)
          (file-exists? FILE))
     (in-file FILE)
     (displayln "bfc: incorrect file provided" (current-error-port))))

;; set run parameters
(when (not (in-file)) (exit 1))
(when (not (out-file))
  (out-file (substring (in-file) 0 (- (string-length (in-file)) 3))))

(when (and (only-asm?) (not (equal? (target) "x86")))
  (run-safe #f "-S available only for x86 target"))

;; run
(match (target)
  ["x86"
   (if (only-asm?)
       (run-safe
        (write-asm-file (parse (file->string (in-file))) (out-file))
        "Could not write .asm file")
       (begin
         (run-safe
          (compile-parsed (parse (file->string (in-file))) (out-file))
          "Erorr while compiling")
         (run-safe
          (delete-immediate-files (out-file))
          "Could not clean up")))]
  ["c"
   (run-safe
    (write-c-file (parse (file->string (in-file))) (out-file))
    "Could not write .c file")]
  [else
   (run-safe #f "Incorrect target (available: x86, C)")])

