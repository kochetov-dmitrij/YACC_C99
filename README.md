# YACC_C99

Process the yacc grammar file
- `yacc -d yacc.y`

Process the lex specification file:
- `lex lex.l`

Compile and link the two C language source files:
- `gcc yacc.tab.c lex.yy.c -o parser`

Run the program
- `./compiler`