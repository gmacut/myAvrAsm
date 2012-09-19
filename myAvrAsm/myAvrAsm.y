%{
#pragma warning(disable: 4065)
#pragma warning(disable: 4083)
#pragma warning(disable: 4996)
#pragma warning(disable: 4273)

#include <cstdio>
#include <cstring>
#include <iostream>

#include <map>

#include "instructions/index.h"
#include "InputFileRecord.h"

using namespace std;

extern int yylex();
extern int yyparse();

extern FILE *yyin;

extern InputFileRecord *__fileStack;

extern std::map<int, Line *> __ASTTopNodes;

extern int __currentlyParsedASTindex;

void yyerror(const char *s);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	class ASTNode *node;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
//%token <ival> INT
//%token <fval> FLOAT
//%token <sval> STRING

%token NEWLINE
%token END_OF_FILE
%token <node> LABEL
%token <node> IDENTIFIER
%token <node> VALUE
%token <node> REGISTER_VALUE

%token OP_EQUALS
%token OP_COMMA

%token EQU
%token DEF
%token DEVICE
%token <node> PRAGMA

%token WHITESPACE

%type <node> EQU_SECOND_ARG_VALUES PSEUDO_COMMAND CONTENT LINE LINE_WITHOUT_LABEL NEWLINES

%%
ALL: END_OF_FILE				{ YYACCEPT; }
	| CONTENT END_OF_FILE		{ 
									std::cout << __ASTTopNodes[__currentlyParsedASTindex]->toString() << std::endl;
									YYACCEPT; 
								}
	;

CONTENT:
	NEWLINES 							
	| CONTENT LINE NEWLINES 			{
											Line *node = new Line;
											node->setContent($2);
											node->setChild(__ASTTopNodes[__currentlyParsedASTindex]);
											__ASTTopNodes[__currentlyParsedASTindex] = node; //new top;
										}
	| CONTENT LINE 						{
											Line *node = new Line;
											node->setContent($2);
											node->setChild(__ASTTopNodes[__currentlyParsedASTindex]);
											__ASTTopNodes[__currentlyParsedASTindex] = node; //new top;
										}				
	;

LINE:
	PRAGMA 								{ 
											Line *node = new Line;
											node->setContent($1);
											$$ = node;
										}
	| LABEL 							{ 
											Line *node = new Line;
											node->setContent($1);
											$$ = node;
										//	std::cout << $$->toString();
										}
	| LABEL LINE_WITHOUT_LABEL  		{ 
											Line *node = new Line;
											node->setContent($1);
											node->setChild($2);
											$$ = node;
										//	std::cout << $$->toString();
										}
	| LINE_WITHOUT_LABEL 				{ 
											$$ = $1; 
										//	std::cout << $$->toString(); 
										}
	;

LINE_WITHOUT_LABEL:
	OPTIONAL_WHITESPACE PSEUDO_COMMAND 	{ 
											Line * node = new Line;
											node->setContent($2);
											$$ = node;
										//	std::cout << $$->toString();
										}
	;

PSEUDO_COMMAND:
	EQU IDENTIFIER OP_EQUALS EQU_SECOND_ARG_VALUES { 
													PseudoEqu *node = new PseudoEqu;
													node->setLeftIdentifier( (Identifier*) $2 );
													node->setRightSide($4);
													$$ = node;
												//	std::cout << $$->toString();
												}
	| DEF IDENTIFIER OP_EQUALS REGISTER_VALUE 	{ 
													PseudoDef *node = new PseudoDef;
													node->setIdentifier( (Identifier*) $2);
													node->setRegister( (Register*) $4);
													$$ = node;
												//	std::cout << $$->toString();
												}
	| DEVICE IDENTIFIER			{ 
									PseudoDevice *node = new PseudoDevice;
									node->setDevice($2->toString());
									$$ = node;
								//	std::cout << $$->toString();
								}
	;

EQU_SECOND_ARG_VALUES:
	VALUE 							{ $$ = $1; }
	| IDENTIFIER 					{ $$ = $1; }
	;

REQUIRED_WHITESPACE:
	WHITESPACE
	;

OPTIONAL_WHITESPACE:	/**/
	| WHITESPACE
	;

NEWLINES: 
	NEWLINES NEWLINE
	| NEWLINE { /*std::cout << std::endl;*/ }
	;
%%


void yyerror(const char *s) {
	cout << "[" << __fileStack->fileName << ":" << __fileStack->lineNum << "]: " << s << endl;
	exit(-1);
}