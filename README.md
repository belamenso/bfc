# Brainfuck compiler with x86 and C backends written in Racket
Written mostly as an exercise to understand x86 NASM Linux assembly, can generate NASM code and assemble it into an ELF executable or generate C code.

Currently both targets support 30,000 8-bit cells with wrapping values (255 + 1 = 0, 0 - 1 = 255).

Output is always finished with `\n\r` (so if a program produces no `\n`, it will be added, and if it does - no additional line feed will be printed).

Generated ELF executable is still dependant on `glibc` (mostly for `system` call to `stty`).
### Cool examples
```
bfc examples/hanoi.bf # draws Hanoi towers
bfc examples/architecture.bf # examine size of bf cells
```
## Dependencies
- x86 target works on 32- and 64-bit Intel machines running Linux
- C target can be compiled and run on basically any system
* `racket`, `raco`
* `nasm`
* `gcc-multilib` (needed to link 32-bit object files on 64-bit machines)

Basically after generating NASM assemly, `bfc` calls `nasm -f elf FILE.asm` and `gcc -m32 FLIE.o`, so if these commands work, everything shoud work correctly).
## Usage
You can run `bfc.rkt` through `racket` or you can compile it (compilation will probably not make it faster). `make` to compile.

`./bfc -h` for command line options

Generate executable `./hw`
```
bfc -o ./hw examples/hello_world.bf
```
Generate only `hanoi.asm` (NASM assembly)
```
bfc -S examples/hanoi.bf
```
Target C code
```
bfc --target C examples/99_bottles.bf
```
## Known bugs and workarounds
### For non-English keyboar layouts (e.g. Polish) and `zsh`
After you run a compiled bf program (either target x86 or compiled output of C target) using `zsh` shell, funny things happen when you try to enter some special characters, like e.g. `ł`. `reset` helps, `stty sane` doesn't do anything.

This probably stems from incorrect usage of `stty`.

`bash` doesn't seem to be affected.
### Uncomfortable command line options
`bfc` uses Racket's `command-line` which means that flags must come before name of the compiled file, so
```
bfc -o hw hello_world.bf
```
is correct, but not
```
bfc hello_world.bf -o hw
```
## TODO
* WebAssembly target
* infinite cell array switch and customizable cell array length
* customizable cell size (8-, 16- and 32-bit)
* play with optimizations, e.g. changing `[-]` to `mov byte[ecx], 0`, currently only trivial ones are implemented (like `-++-++++` becomes `add byte[ecx], 4`)
