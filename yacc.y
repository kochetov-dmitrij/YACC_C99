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

Node *root;
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
	: cast_expression {$$ = $1;}
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
	: declaration_specifiers ';' {$$ = $1;}
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
	: struct_declaration {$$ = new Node("Struct declaration", $1);}
	| struct_declaration_list struct_declaration {$$ = new Node("Struct declaration list", $1, $2);}
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' {$$ = new Node("Struct declarator", $1, $2);}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {$$ = new Node("Specifier list", $1, $2);}
	| type_specifier {$$ = new Node("Specifier", $1);}
	| type_qualifier specifier_qualifier_list {$$ = new Node("Qualifier list", $1, $2);}
	| type_qualifier {$$ = new Node("Qualifier", $1);}
	;

struct_declarator_list
	: struct_declarator {$$ = new Node("Struct declarator", $1);}
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
	: IDENTIFIER {$$ = new Node("Identifier", $1);}
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
	: IDENTIFIER {$$ = new Node("Identifier", $1);}
	| '(' declarator ')' {$$ = new Node("Direct declarator", $2);}
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {$$ = new Node("Direct declarator", $1, $3, $4);}
	| direct_declarator '[' type_qualifier_list ']' {$$ = new Node("Direct declarator", $1, $3);}
	| direct_declarator '[' assignment_expression ']' {$$ = new Node("Direct declarator", $1, $3);}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']' {$$ = new Node("Direct declarator", $1, $3, $4, $5);}
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' {$$ = new Node("Direct declarator", $1, $3, $4, $5);}
	| direct_declarator '[' type_qualifier_list '*' ']' {$$ = new Node("Direct declarator", $1, $3);}
	| direct_declarator '[' '*' ']' {$$ = new Node("Direct declarator", $1);}
	| direct_declarator '[' ']' {$$ = new Node("Direct declarator", $1);}
	| direct_declarator '(' parameter_type_list ')' {$$ = new Node("Direct declarator", $1, $3);}
	| direct_declarator '(' identifier_list ')' {$$ = new Node("Direct declarator", $1, $3);}
	| direct_declarator '(' ')' {$$ = new Node("Direct declarator", $1);}
	;

pointer
	: '*' {$$ = new Node("Pointer", $1);}
	| '*' type_qualifier_list{$$ = new Node("Pointer", $1, $2);}
	| '*' pointer {$$ = new Node("Pointer", $1, $2);}
	| '*' type_qualifier_list pointer{$$ = new Node("Pointer", $1, $2, $3);}
	;

type_qualifier_list
	: type_qualifier {$$ = new Node("Type qualifier list", $1);}
	| type_qualifier_list type_qualifier {$$ = new Node("Type qualifier list", $1, $2);}
	;


parameter_type_list
	: parameter_list {$$ = new Node("Parameter type list", $1);}
	| parameter_list ',' ELLIPSIS {$$ = new Node("Parameter type list", $1, $3);}
	;

parameter_list
	: parameter_declaration {$$ = $1;}
	| parameter_list ',' parameter_declaration {$$ = new Node("Parameter list", $1, $3);}
	;

parameter_declaration
	: declaration_specifiers declarator {$$ = new Node("Parameter declaration", $1, $2);}
	| declaration_specifiers abstract_declarator {$$ = new Node("Parameter declaration", $1, $2);}
	| declaration_specifiers {$$ = new Node("Parameter declaration", $1);}
	;

identifier_list
	: IDENTIFIER {$$ = new Node("Identifier", $1);}
	| identifier_list ',' IDENTIFIER {$$ = new Node("Identifier list", $1, $3);}
	;

type_name
	: specifier_qualifier_list {$$ = new Node("Type name", $1);}
	| specifier_qualifier_list abstract_declarator {$$ = new Node("Type name", $1, $2);}
	;

abstract_declarator
	: pointer {$$ = new Node("Abstract declarator", $1);}
	| direct_abstract_declarator {$$ = new Node("Abstract declarator", $1);}
	| pointer direct_abstract_declarator {$$ = new Node("Abstract declarator", $1, $2);}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')' {$$ = new Node("Abstract declarator"), $2;}
	| '[' ']' {$$ = new Node("Empty square brackets");}
	| '[' assignment_expression ']' {$$ = new Node("Square brackets with AE");}
	| direct_abstract_declarator '[' ']' {$$ = new Node("Empty square DAD");}
	| direct_abstract_declarator '[' assignment_expression ']' {$$ = new Node("Square DAD", $3);}
	| '[' '*' ']' {$$ = new Node("Square brackets with pointer");}
	| direct_abstract_declarator '[' '*' ']' {$$ = new Node("DAD with pointer");}
	| '(' ')' {$$ = new Node("Empty parentheses");}
	| '(' parameter_type_list ')' {$$ = new Node("Parentheses", $2);}
	| direct_abstract_declarator '(' ')' {$$ = new Node("DAD", $3);}
	| direct_abstract_declarator '(' parameter_type_list ')' {$$ = new Node("DAD", $3);}
	;

initializer
	: assignment_expression {$$ = new Node("Initializer", $1);}
	| '{' initializer_list '}' {$$ = new Node("Initializer", $2);}
	| '{' initializer_list ',' '}' {$$ = new Node("Initializer", $2);}
	;

initializer_list
	: initializer {$$ = new Node("Initializer list", $1);}
	| designation initializer {$$ = new Node("Initializer list", $1, $2);}
	| initializer_list ',' initializer {$$ = new Node("Initializer list", $1, $3);}
	| initializer_list ',' designation initializer {$$ = new Node("Initializer list", $1, $3, $4);}
	;

designation
	: designator_list '=' {$$ = new Node("Designator", $1, $2);}
	;

designator_list
	: designator {$$ = new Node("Designator list", $1);}
	| designator_list designator {$$ = new Node("Designator list", $1, $2);}
	;

designator
	: '[' constant_expression ']' {$$ = new Node("Array Element", $2);}
	| '.' IDENTIFIER  {$$ = new Node("Inner Characteristic", $2);}
	;

statement
	: labeled_statement {$$ = new Node("Labeled statement", $1);}
	| compound_statement {$$ = new Node("Compound statement", $1);}
	| expression_statement {$$ = new Node("Expression statement", $1);}
	| selection_statement {$$ = new Node("Selection statement", $1);}
	| iteration_statement {$$ = new Node("Iteration statement", $1);}
	| jump_statement {$$ = $1;}
	;

labeled_statement
	: IDENTIFIER ':' statement {$$ = new Node("Labled statement ", $1, $3);}
	| CASE constant_expression ':' statement {$$ = new Node("Case ", $2, $4);}
	| DEFAULT ':' statement {$$ = new Node("Default ", $3);}
	;

compound_statement
	: '{' '}' {$$ = new Node("Empty Declaration", $1, $2);}
	| '{' block_item_list '}' {$$ = new Node("Block item list", $2);}
	;

block_item_list
	: block_item {$$ = new Node("Block item", $1);}
	| block_item_list block_item {$$ = new Node("Block item list", $1, $2);}
	;

block_item
	: declaration {$$ = new Node("Declaration", $1);}
	| statement {$$ = $1; }
	;

expression_statement
	: ';' {$$ = new Node("Semicolon");}
	| expression ';' {$$ = new Node("Expression", $1);}
	;

selection_statement
	: IF '(' expression ')' statement {$$ = new Node("If", $3, $5);}
	| IF '(' expression ')' statement ELSE statement {$$ = new Node("IfElse", $3, $5, $7);}
	| SWITCH '(' expression ')' statement {$$ = new Node("Switch", $3, $5);}
	;

iteration_statement
	: WHILE '(' expression ')' statement {$$ = new Node("While", $3, $5);}
	| DO statement WHILE '(' expression ')' ';' {$$ = new Node("DoWhile", $2, $5);}
	| FOR '(' expression_statement expression_statement ')' statement {$$ = new Node("For", $3, $4, $6);}
	| FOR '(' expression_statement expression_statement expression ')' statement {$$ = new Node("For", $3, $4, $5, $7);}
	| FOR '(' declaration expression_statement ')' statement {$$ = new Node("For", $3, $4, $6);}
	| FOR '(' declaration expression_statement expression ')' statement {$$ = new Node("For", $3, $4, $5, $7);}
	;

jump_statement
	: GOTO IDENTIFIER ';' {$$ = new Node("Goto", $1);}
	| CONTINUE ';' {$$ = new Node("Continue");}
	| BREAK ';' {$$ = new Node("Break");}
	| RETURN ';' {$$ = new Node("Return");}
	| RETURN expression ';' {$$ = new Node("Return", $2);}
	;

translation_unit
	: external_declaration {$$ = new Node("translation unit", $1); root = $$;}
 	| translation_unit external_declaration {$$ = new Node("external declaration", $1, $2); root = $$;}
	;

external_declaration
	: function_definition {$$ = $1;}
	| declaration {$$ = new Node("Declaration", $1);}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement {$$ = new Node("Function definition", $1, $2, $3, $4);}
	| declaration_specifiers declarator compound_statement {$$ = new Node("Function definition", $1, $2, $3);}
	;

declaration_list
	: declaration {$$ = new Node("Declaration", $1);}
	| declaration_list declaration {$$ = new Node("Declaration list", $1, $2);}
	;


%%
extern char yytext[];
extern int column;

void yyerror(char const *s)
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}

void printTree(const std::string &prefix, const Node *node, bool is_last) {
        if (node != nullptr) {

                std::cout << prefix;
                std::cout << (is_last ? "└──" : "├──");
                std::cout << node->name << std::endl;

                if (node->left != nullptr) {
                        printTree(prefix + (is_last ? "    " : "│   "), node->left, !node->right);
                }
                if (node->right != nullptr) {
                        printTree(prefix + (is_last ? "    " : "│   "), node->right, !node->third);
                }
                if (node->third != nullptr) {
                        printTree(prefix + (is_last ? "    " : "│   "), node->third, !node->fourth);
                }
                if (node->fourth != nullptr) {
                        printTree(prefix + "    ", node->fourth, true);
                }
        }
}

void printTree(const Node* node)
{
	std::cout << "\n\n===== Tree =====\n\n";
    	printTree("", node, true);
}

int main(int argc, char* argv[])
{
	if (argc != 2) {
		std::cout << "Expected 1 argument: Pass filename as an argument" << std::endl;
		return 1;
	}
	yyin = fopen(argv[1], "r");
	yyparse();
	if (root != nullptr) printTree(root);

	return 0;
}
