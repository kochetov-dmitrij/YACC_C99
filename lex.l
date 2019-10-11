%{
#include <stdio.h>
#include "yacc.hpp"
#include <iostream>

void count(void);
void comment(void);
extern void yyerror(const char *);
%}

D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			([Ee][+-]?{D}+)
P                       ([Pp][+-]?{D}+)
FS			(f|F|l|L)
IS                      ((u|U)|(u|U)?(l|L|ll|LL)|(l|L|ll|LL)(u|U))

%%
"/*"            { comment(); }
"//"[^\n]*      { }

"auto"			{ yylval = new Node(yytext); count(); return(AUTO); }
"_Bool"			{ yylval = new Node(yytext); count(); return(BOOL); }
"break"			{ yylval = new Node(yytext); count(); return(BREAK); }
"case"			{ yylval = new Node(yytext); count(); return(CASE); }
"char"			{ yylval = new Node(yytext); count(); return(CHAR); }
"_Complex"		{ yylval = new Node(yytext); count(); return(COMPLEX); }
"const"			{ yylval = new Node(yytext); count(); return(CONST); }
"continue"		{ yylval = new Node(yytext); count(); return(CONTINUE); }
"default"		{ yylval = new Node(yytext); count(); return(DEFAULT); }
"do"			{ yylval = new Node(yytext); count(); return(DO); }
"double"		{ yylval = new Node(yytext); count(); return(DOUBLE); }
"else"			{ yylval = new Node(yytext); count(); return(ELSE); }
"enum"			{ yylval = new Node(yytext); count(); return(ENUM); }
"extern"		{ yylval = new Node(yytext); count(); return(EXTERN); }
"float"			{ yylval = new Node(yytext); count(); return(FLOAT); }
"for"			{ yylval = new Node(yytext); count(); return(FOR); }
"goto"			{ yylval = new Node(yytext); count(); return(GOTO); }
"if"			{ yylval = new Node(yytext); count(); return(IF); }
"_Imaginary"    { yylval = new Node(yytext); count(); return(IMAGINARY); }
"inline"		{ yylval = new Node(yytext); count(); return(INLINE); }
"int"			{ yylval = new Node(yytext); count(); return(INT); }
"long"			{ yylval = new Node(yytext); count(); return(LONG); }
"register"		{ yylval = new Node(yytext); count(); return(REGISTER); }
"restrict"		{ yylval = new Node(yytext); count(); return(RESTRICT); }
"return"		{ yylval = new Node(yytext); count(); return(RETURN); }
"short"			{ yylval = new Node(yytext); count(); return(SHORT); }
"signed"		{ yylval = new Node(yytext); count(); return(SIGNED); }
"sizeof"		{ yylval = new Node(yytext); count(); return(SIZEOF); }
"static"		{ yylval = new Node(yytext); count(); return(STATIC); }
"struct"		{ yylval = new Node(yytext); count(); return(STRUCT); }
"switch"		{ yylval = new Node(yytext); count(); return(SWITCH); }
"typedef"		{ yylval = new Node(yytext); count(); return(TYPEDEF); }
"union"			{ yylval = new Node(yytext); count(); return(UNION); }
"unsigned"		{ yylval = new Node(yytext); count(); return(UNSIGNED); }
"void"			{ yylval = new Node(yytext); count(); return(VOID); }
"volatile"		{ yylval = new Node(yytext); count(); return(VOLATILE); }
"while"			{ yylval = new Node(yytext); count(); return(WHILE); }

{L}({L}|{D})*		{ yylval = new Node(yytext); count(); return(IDENTIFIER); }

0[xX]{H}+{IS}?		{ yylval = new Node(yytext); count(); return(CONSTANT); }
0[0-7]*{IS}?		{ yylval = new Node(yytext); count(); return(CONSTANT); }
[1-9]{D}*{IS}?		{ yylval = new Node(yytext); count(); return(CONSTANT); }
L?'(\\.|[^\\'\n])+'	{ yylval = new Node(yytext); count(); return(CONSTANT); }

{D}+{E}{FS}?		        { yylval = new Node(yytext); count(); return(CONSTANT); }
{D}*"."{D}+{E}?{FS}?	    { yylval = new Node(yytext); count(); return(CONSTANT); }
{D}+"."{D}*{E}?{FS}?	    { yylval = new Node(yytext); count(); return(CONSTANT); }
0[xX]{H}+{P}{FS}?	        { yylval = new Node(yytext); count(); return(CONSTANT); }
0[xX]{H}*"."{H}+{P}?{FS}?   { yylval = new Node(yytext); count(); return(CONSTANT); }
0[xX]{H}+"."{H}*{P}?{FS}?   { yylval = new Node(yytext); count(); return(CONSTANT); }


L?\"(\\.|[^\\"\n])*\"	{ yylval = new Node(yytext); count(); return(STRING_LITERAL); }

"..."			{ yylval = new Node(yytext); count(); return(ELLIPSIS); }
">>="			{ yylval = new Node(yytext); count(); return(RIGHT_ASSIGN); }
"<<="			{ yylval = new Node(yytext); count(); return(LEFT_ASSIGN); }
"+="			{ yylval = new Node(yytext); count(); return(ADD_ASSIGN); }
"-="			{ yylval = new Node(yytext); count(); return(SUB_ASSIGN); }
"*="			{ yylval = new Node(yytext); count(); return(MUL_ASSIGN); }
"/="			{ yylval = new Node(yytext); count(); return(DIV_ASSIGN); }
"%="			{ yylval = new Node(yytext); count(); return(MOD_ASSIGN); }
"&="			{ yylval = new Node(yytext); count(); return(AND_ASSIGN); }
"^="			{ yylval = new Node(yytext); count(); return(XOR_ASSIGN); }
"|="			{ yylval = new Node(yytext); count(); return(OR_ASSIGN); }
">>"			{ yylval = new Node(yytext); count(); return(RIGHT_OP); }
"<<"			{ yylval = new Node(yytext); count(); return(LEFT_OP); }
"++"			{ yylval = new Node(yytext); count(); return(INC_OP); }
"--"			{ yylval = new Node(yytext); count(); return(DEC_OP); }
"->"			{ yylval = new Node(yytext); count(); return(PTR_OP); }
"&&"			{ yylval = new Node(yytext); count(); return(AND_OP); }
"||"			{ yylval = new Node(yytext); count(); return(OR_OP); }
"<="			{ yylval = new Node(yytext); count(); return(LE_OP); }
">="			{ yylval = new Node(yytext); count(); return(GE_OP); }
"=="			{ yylval = new Node(yytext); count(); return(EQ_OP); }
"!="			{ yylval = new Node(yytext); count(); return(NE_OP); }
";"		    	{ yylval = new Node(yytext); count(); return(';'); }
("{"|"<%")		{ yylval = new Node(yytext); count(); return('{'); }
("}"|"%>")		{ yylval = new Node(yytext); count(); return('}'); }
","		    	{ yylval = new Node(yytext); count(); return(','); }
":"		    	{ yylval = new Node(yytext); count(); return(':'); }
"="		    	{ yylval = new Node(yytext); count(); return('='); }
"("		    	{ yylval = new Node(yytext); count(); return('('); }
")"		    	{ yylval = new Node(yytext); count(); return(')'); }
("["|"<:")		{ yylval = new Node(yytext); count(); return('['); }
("]"|":>")		{ yylval = new Node(yytext); count(); return(']'); }
"."		    	{ yylval = new Node(yytext); count(); return('.'); }
"&"			    { yylval = new Node(yytext); count(); return('&'); }
"!"	    		{ yylval = new Node(yytext); count(); return('!'); }
"~"	    		{ yylval = new Node(yytext); count(); return('~'); }
"-"	    		{ yylval = new Node(yytext); count(); return('-'); }
"+"	    		{ yylval = new Node(yytext); count(); return('+'); }
"*"	    		{ yylval = new Node(yytext); count(); return('*'); }
"/"	    		{ yylval = new Node(yytext); count(); return('/'); }
"%"	    		{ yylval = new Node(yytext); count(); return('%'); }
"<"	    		{ yylval = new Node(yytext); count(); return('<'); }
">"	    		{ yylval = new Node(yytext); count(); return('>'); }
"^"	    		{ yylval = new Node(yytext); count(); return('^'); }
"|"		    	{ yylval = new Node(yytext); count(); return('|'); }
"?"		    	{ yylval = new Node(yytext); count(); return('?'); }

[ \t\v\n\f]		{ yylval = new Node(yytext); count(); }
.			    { yylval = new Node(yytext); yyerror("Unmatched characters"); return 0; }

%%

int yywrap(void)
{
	return 1;
}

void comment(void)
{
	char c, prev = 0;
  
	while ((c = yyinput()) != 0)      /* (EOF maps to 0) */
	{
		if (c == '/' && prev == '*')
			return;
		prev = c;
	}
	yyerror("Unterminated comment");
}


int column = 0;

void count(void)
{
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;
	ECHO;
}
