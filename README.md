# YACC_C99

run.sh does the following:

> Process the yacc grammar file:\
> `yacc.y` -> (bison) -> `yacc.c`, `yacc.h`
>
> Process the lex specification file:\
> `lex.l` -> (flex) -> `lex.c`
>
> Compile and link the two C language source files:\
> `yacc.c`, `lex.c`  -> `parser`
>
> Run the program\
> `./parser input.txt`