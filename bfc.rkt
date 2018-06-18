#lang racket

(require "./frontend.rkt"
         "./parameters.rkt"
         "./x86/backend.rkt"
         "./C/backend.rkt")

(define (run-safe test error-msg)
  (when (not test)
    (displayln (string-append "bfc: " error-msg) (current-error-port))
    (exit 1)))

(define (path->out-file-name path)
    (let-values ([(_ name __) (split-path path)])
          (let ([str-name (path->string name)])
                  (substring str-name 0 (- (string-length str-name) 3)))))

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
 [("--cell-size" "--cs")
  n
  "Size in bits of a single bf cell (available: 8, 16, 32). Default size: 8"
  (let ([n (string->number n)])
    (if (member n '(8 16 32))
        (cell-size n)
        (run-safe #f "Incorrect cell size (available: 8, 16, 32)")))]
 [("--tape-length" "--len")
  n
  "Size of bf cell tape. Positive integer. Default length: 30,000"
  (let ([n (string->number n)])
    (if ((and/c integer? positive?) n)
        (tape-length n)
        (run-safe #f "Tape length not a positive integer.")))]
 #:args (FILE)
 (cond
   [(not (regexp-match #rx".+\\.bf$" FILE)) (run-safe #f "File doesn't end with .bf")]
   [(not (file-exists? FILE)) (run-safe #f "File does not exist")]
   [else (in-file FILE)]))

;; set run parameters
(when (not (in-file)) (exit 1))
(when (not (out-file))
  (out-file (path->out-file-name (in-file))))

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

