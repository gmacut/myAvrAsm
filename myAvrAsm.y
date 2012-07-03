%{

#include <cstdio>
#include <iostream>

#include "InputFileRecord.h"

using namespace std;

extern int yylex();
extern int yyparse();

extern FILE *yyin;

extern InputFileRecord *__fileStack;

void yyerror(const char *s);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
//%union {
//	int ival;
//	float fval;
//	char *sval;
//}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
//%token <ival> INT
//%token <fval> FLOAT
//%token <sval> STRING

%token NEWLINE
//%token INCLUDE
//%token ORG
//%token EQU
//%token DEF

//%token RJMP
//%token LDI
//%token OUT
//%token SER



%%

top:
	LINE NEWLINES 	
	| NEWLINES 			
	;

LINE:
	DIRECTIVE NEWLINES
	| LABEL NEWLINES
	| LABEL DIRECTIVE NEWLINES
	;

LABEL:
	//IDENTIFIER ':'
	;

DIRECTIVE:
	PSEUDOCOMMAND
	| COMMAND
	;

PSEUDOCOMMAND:
	;

COMMAND:
	;

NEWLINES: 
	NEWLINES NEWLINE
	| NEWLINE
	;
%%


void yyerror(const char *s) {
	cout << "[" << __fileStack->fileName << ":" << __fileStack->lineNum << "]: " << s << endl;
	exit(-1);
}