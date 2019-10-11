%{
#include <cstdio>
#include <stdio.h>
#include <iostream>
#include <string>
#include "string.h"
#include "node.h"

int yylex(void);
extern "C" int yyparse();
extern "C" FILE *yyin;

#define YYSTYPE Node*

void yyerror(char const *s);
%}

%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token BOOL COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN


%start translation_unit
%%

primary_expression
	: IDENTIFIER {$$ = new Node("Identifier", $1);}
	| CONSTANT {$$ = new Node("Constant", $1);}
	| STRING_LITERAL {$$ = new Node("String literal", $1);}
	| '(' expression ')' {$$ = new Node("Expression", $2);}
	;

postfix_expression
	: primary_expression {$$ = $1;}
	| postfix_expression '[' expression ']' {$$ = new Node("Postfix expression", $1, $3);}
	| postfix_expression '(' ')' {$$ = new Node("Postfix expression", $1);}
	| postfix_expression '(' argument_expression_list ')' {$$ = new Node("Postfix expression", $1, $3);}
	| postfix_expression '.' IDENTIFIER {$$ = new Node("Postfix expression", $1, $3);}
	| postfix_expression PTR_OP IDENTIFIER {$$ = new Node("Postfix expression pointer", $1, $3);}
	| postfix_expression INC_OP {$$ = new Node("Postfix expression incremented", $1);}
	| postfix_expression DEC_OP {$$ = new Node("Postfix expression decremented", $1);}
	| '(' type_name ')' '{' initializer_list '}' {$$ = new Node("Postfix expression", $2, $5);}
	| '(' type_name ')' '{' initializer_list ',' '}' {$$ = new Node("Postfix expression", $2, $5);}
	;

argument_expression_list
	: assignment_expression {$$ = $1;}
	| argument_expression_list ',' assignment_expression {$$ = new Node("Argument expression list", $1, $3);}
	;

unary_expression
	: postfix_expression {$$ = $1;}
	| INC_OP unary_expression {$$ = new Node("Increment", $2);}
	| DEC_OP unary_expression {$$ = new Node("Decrement", $2);}
	| unary_operator cast_expression {$$ = new Node("Unary operation", $1, $2);}
	| SIZEOF unary_expression {$$ = new Node("Size of", $2);}
	| SIZEOF '(' type_name ')' {$$ = new Node("Size of type", $3);}
	;

unary_operator
	: '&' {$$ = new Node("Unary and");}
	| '*' {$$ = new Node("Pointer");}
	| '+' {$$ = new Node("Unary plus");}
	| '-' {$$ = new Node("Unary minus");}
	| '~' {$$ = new Node("Invert bits");}
	| '!' {$$ = new Node("Not");}
	;

cast_expression
	: unary_expression {$$ = $1;}
	| '(' type_name ')' cast_expression {$$ = new Node("Cast", $1);}
	;

multiplicative_expression
	: cast_expression {$$ = $1}
	| multiplicative_expression '*' cast_expression {$$ = new Node("Multiply", $1, $3);}
	| multiplicative_expression '/' cast_expression {$$ = new Node("Divide", $1, $3);}
	| multiplicative_expression '%' cast_expression {$$ = new Node("Modulo", $1, $3);}
	;

additive_expression
	: multiplicative_expression {$$ = $1;}
	| additive_expression '+' multiplicative_expression {$$ = new Node("Add", $1, $3);}
	| additive_expression '-' multiplicative_expression {$$ = new Node("Sub", $1, $3);}
	;

shift_expression
	: additive_expression {$$ = $1;}
	| shift_expression LEFT_OP additive_expression {$$ = new Node("Left shift", $1, $3);}
	| shift_expression RIGHT_OP additive_expression {$$ = new Node("Right shift", $1, $3);}
	;

relational_expression
	: shift_expression {$$ = $1;}
	| relational_expression '<' shift_expression {$$ = new Node("Less", $1, $3);}
	| relational_expression '>' shift_expression {$$ = new Node("More", $1, $3);}
	| relational_expression LE_OP shift_expression  {$$ = new Node("Less or equal", $1, $3);}
	| relational_expression GE_OP shift_expression {$$ = new Node("More or equal", $1, $3);}
	;

equality_expression
	: relational_expression {$$ = $1;}
	| equality_expression EQ_OP relational_expression {$$ = new Node("Equals", $1, $3);}
	| equality_expression NE_OP relational_expression {$$ = new Node("Not equals", $1, $3);}
	;

and_expression
	: equality_expression {$$ = $1;}
	| and_expression '&' equality_expression {$$ = new Node("And", $1, $2);}
	;

exclusive_or_expression
	: and_expression {$$ = $1;}
	| exclusive_or_expression '^' and_expression {$$ = new Node("Exclusive or", $1, $3);}
	;

inclusive_or_expression
	: exclusive_or_expression {$$ = $1;}
	| inclusive_or_expression '|' exclusive_or_expression {$$ = new Node("Inclusive or", $1, $3);}
	;

logical_and_expression
	: inclusive_or_expression {$$ = $1;}
	| logical_and_expression AND_OP inclusive_or_expression {$$ = new Node("Logical and", $1, $3);}
	;

logical_or_expression
	: logical_and_expression {$$ = $1;}
	| logical_or_expression OR_OP logical_and_expression {$$ = new Node("Logical or", $1, $3);}
	;

conditional_expression
	: logical_or_expression {$$ = $1;}
	| logical_or_expression '?' expression ':' conditional_expression {$$ = new Node("Ternary condition", $1, $3, $5);}
	;

assignment_expression
	: conditional_expression {$$ = $1;}
	| unary_expression assignment_operator assignment_expression {$$ = new Node("Assignment", $1, $2, $3);}
	;

assignment_operator
	: '=' {$$ = $1;}
	| MUL_ASSIGN {$$ = $1;}
	| DIV_ASSIGN {$$ = $1;}
	| MOD_ASSIGN {$$ = $1;}
	| ADD_ASSIGN {$$ = $1;} 
	| SUB_ASSIGN {$$ = $1;}
	| LEFT_ASSIGN {$$ = $1;}
	| RIGHT_ASSIGN {$$ = $1;}
	| AND_ASSIGN {$$ = $1;}
	| XOR_ASSIGN {$$ = $1;}
	| OR_ASSIGN {$$ = $1;}
	;

expression
	: assignment_expression {$$ = $1;}
	| expression ',' assignment_expression {$$ = new Node("Expression", $1, $3);}
	;

constant_expression
	: conditional_expression {$$ = $1;}
	;

declaration
	: declaration_specifiers ';' {$$ = $1}
	| declaration_specifiers init_declarator_list ';' {$$ = new Node("Declaration", $1, $2);}
	;

declaration_specifiers
	: storage_class_specifier {$$ = $1;}
	| storage_class_specifier declaration_specifiers {$$ = new Node("Declaration specifiers", $1, $2);}
	| type_specifier {$$ = $1;}
	| type_specifier declaration_specifiers {$$ = new Node("Declaration specifiers", $1, $2);}
	| type_qualifier {$$ = $1;}
	| type_qualifier declaration_specifiers {$$ = new Node("Declaration specifiers", $1, $2);}
	| function_specifier {$$ = $1;}
	| function_specifier declaration_specifiers {$$ = new Node("Declaration specifiers", $1, $2);}
	;

init_declarator_list
	: init_declarator {$$ = $1;}
	| init_declarator_list ',' init_declarator {$$ = new Node("Init declarator list", $1, $3);}
	;

init_declarator
	: declarator {$$ = $1;}
	| declarator '=' initializer {$$ = new Node("Init declarator", $1, $3);}
	;

storage_class_specifier
	: TYPEDEF {$$ = $1;}
	| EXTERN {$$ = $1;}
	| STATIC {$$ = $1;}
	| AUTO {$$ = $1;}
	| REGISTER {$$ = $1;}
	;

type_specifier
	: VOID {$$ = $1;}
	| CHAR {$$ = $1;}
	| SHORT {$$ = $1;}
	| INT {$$ = $1;}
	| LONG {$$ = $1;}
	| FLOAT {$$ = $1;}
	| DOUBLE {$$ = $1;}
	| SIGNED {$$ = $1;}
	| UNSIGNED {$$ = $1;}
	| BOOL {$$ = $1;}
	| COMPLEX {$$ = $1;}
	| IMAGINARY {$$ = $1;}
	| struct_or_union_specifier {$$ = $1;}
	| enum_specifier {$$ = $1;}
	| TYPE_NAME {$$ = $1;}
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}' {$$ = new Node("Struct or union specifier", $1, $2, $4);}
	| struct_or_union '{' struct_declaration_list '}'  {$$ = new Node("Struct or union specifier", $1, $3);}
	| struct_or_union IDENTIFIER {$$ = new Node("Struct or union specifier", $1, $2);}
	;

struct_or_union
	: STRUCT {$$ = $1;}
	| UNION {$$ = $1;}
	;

struct_declaration_list
	: struct_declaration {$$ = $1;}
	| struct_declaration_list struct_declaration {$$ = new Node("Struct declaration list", $1, $2);}
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' {$$ = new Node("Struct declarator", $1, $2);}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {$$ = new Node("Specifier qualifier list", $1, $2);}
	| type_specifier {$$ = $1;}
	| type_qualifier specifier_qualifier_list {$$ = new Node("Specifier qualifier list", $1, $2);}
	| type_qualifier {$$ = $1;}
	;

struct_declarator_list
	: struct_declarator {$$ = $1;}
	| struct_declarator_list ',' struct_declarator {$$ = new Node("Struct declarator list", $1, $3);}
	;

struct_declarator
	: declarator {$$ = $1;}
	| ':' constant_expression {$$ = new Node("Struct declarator", $2);}
	| declarator ':' constant_expression {$$ = new Node("Struct declarator", $1, $3);}
	;

enum_specifier
	: ENUM '{' enumerator_list '}'  {$$ = new Node("Enum specifier", $1, $3);}
	| ENUM IDENTIFIER '{' enumerator_list '}' {$$ = new Node("Enum specifier", $1, $2, $4);}
	| ENUM '{' enumerator_list ',' '}' {$$ = new Node("Enum specifier", $1, $3);}
	| ENUM IDENTIFIER '{' enumerator_list ',' '}' {$$ = new Node("Enum specifier", $1, $2, $4);}
	| ENUM IDENTIFIER {$$ = new Node("Enum specifier", $1, $2);}
	;

enumerator_list
	: enumerator {$$ = $1;}
	| enumerator_list ',' enumerator {$$ = new Node("Enumerator list", $1, $3);}
	;

enumerator
	: IDENTIFIER {$$ = $1;}
	| IDENTIFIER '=' constant_expression {$$ = new Node("Enumerator", $1, $3);}
	;

type_qualifier
	: CONST {$$ = $1;}
	| RESTRICT {$$ = $1;}
	| VOLATILE {$$ = $1;}
	;

function_specifier
	: INLINE {$$ = $1;}
	;

declarator
	: pointer direct_declarator {$$ = new Node("Delcarator", $1, $2);}
	| direct_declarator {$$ = $1;}
	;


direct_declarator
	: IDENTIFIER
	| '(' declarator ')'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;

pointer
	: '*'
	| '*' type_qualifier_list
	| '*' pointer
	| '*' type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '[' '*' ']'
	| direct_abstract_declarator '[' '*' ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| designation initializer
	| initializer_list ',' initializer
	| initializer_list ',' designation initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' block_item_list '}'
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration
	| declaration_list declaration
	;


%%
extern char yytext[];
extern int column;

void yyerror(char const *s)
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}

int main(int argc, char* argv[])
{
    if (argc != 2) {
    	std::cout << "Expected 1 argument: Pass filename as an argument" << std::endl;
    	return 1;
    }
    yyin = fopen(argv[1],"r");
    yyparse();
    return 0;
}
