#!/usr/bin/env bash
bison -d --output yacc.cpp yacc.y
flex -o lex.cpp lex.l
g++ yacc.cpp lex.cpp -o parser
rm yacc.cpp yacc.hpp lex.cpp
./parser input.txt
