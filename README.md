# YACC_C99

Structure:

```
.
├── README.md
├── input.txt
├── lex.l
├── node.h
├── parser
├── run.sh
└── yacc.y
```

run.sh does the following:

> Process the yacc grammar file:\
> `yacc.y` -> (bison) -> `yacc.cpp`, `yacc.hpp`
>
> Process the lex specification file:\
> `lex.l` -> (flex) -> `lex.cpp`
>
> Compile and link the two C language source files:\
> `yacc.cpp`, `lex.cpp`  -> `parser`
>
> Run the program\
> `./parser input.txt`

Output:
