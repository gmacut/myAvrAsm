%{
#include "InputFileRecord.h"
#include "myAvrAsm.tab.h"

#include <iostream>
#include <cstring>

#include <string>
#include <set>

using namespace std;

#define YY_DECL extern int yylex()




/*****************************************
				GLOBALS
*****************************************/
extern InputFileRecord *__fileStack;

/**
 * Set containing all defined elements (preprocessor
 * #DEFINE statement)
 */
extern std::set<std::string> __defines;



/*****************************************
*				YY_BUFFER STACK
*
* include files support requires lex to 
* have separate buffers for every file read
* at the same time
******************************************/
#define MAX_INCLUDE_DEPTH 20

YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];

int include_stack_ptr = 0;



/*******************************************
				LOCAL GLOBALS
*******************************************/
std::set<std::string> _pragmaOnceDefines;


%}



%option noyywrap
%x incl
%x multilineComment
%x preprocessorIgnore



%%



	
[.#][Ii][Nn][Cc][Ll][Uu][Dd][Ee][ \t]*[\"<] 	BEGIN(incl);

<incl>[^ \t\n]+[\">]   { 
						
					/* 	
					 *	Captures .include "file" statement. Opens included file and starts to 
					 *	read from it. 
					 */
						/* got the include file name + final character " */
                 		yytext[yyleng-1] = '\0';
                 		InputFileRecord *newFile = new InputFileRecord;
                 		newFile->fileName = strdup(yytext);
                 		newFile->lineNum = 1;
                 		newFile->file = fopen(newFile->fileName, "r");
                 		if (!(newFile->file)){
                 			std::cerr 	<< "[" << __fileStack->fileName 
                 						<< ":" << __fileStack->lineNum 
                 						<< "]: Unable to open include file " 
                 						<< newFile->fileName
                 						<< std::endl;
                 		} else {
                 			if ( include_stack_ptr >= MAX_INCLUDE_DEPTH ){
                     			std::cerr << "Includes nested too deep" << std::endl;
                     			exit( 1 );
                     		}
                     		include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;

                     		newFile->previous = __fileStack;
                 			__fileStack = newFile;
                 			yyin = __fileStack->file;
                 			
                 			yy_switch_to_buffer( yy_create_buffer( yyin, YY_BUF_SIZE ) );

                 			std::cout << "Reading from included file:" << __fileStack->fileName << std::endl;
                 		}     					
           		     	BEGIN(INITIAL);
                 	}
     
     
				
;.\n 				{ 
					/**
					 * Comments that begin with ; and span to the end of the line
					 */	
						__fileStack->lineNum++; 
					}



\/\*				BEGIN(multilineComment);

<multilineComment>\*\/ BEGIN(INITIAL);

<multilineComment>\n { 
					/**
					* Newline. Increases line count
					*/
 						__fileStack->lineNum++; 
 					}

<multilineComment>. ;





#define.*\n 		{
						__defines.insert(yytext+7);
					}

#ifdef.*\n 			{
						if (__defines.find(yytext+6) == __defines.end()){
							BEGIN(preprocessorIgnore);
						}
					} 	

#ifndef.*\n 		{
						if (__defines.find(yytext+7) != __defines.end()){
							BEGIN(preprocessorIgnore);
						}
					}

#pragma[ \t]once		{
						if (_pragmaOnceDefines.find(std::string(__fileStack->fileName)) != _pragmaOnceDefines.end()){
							BEGIN(preprocessorIgnore);
						} else {
							_pragmaOnceDefines.insert(std::string(__fileStack->fileName));
						}
					}

<preprocessorIgnore>.	;

<preprocessorIgnore>\n  { std::cout << "."; 
						__fileStack->lineNum++; }

<preprocessorIgnore>#endif 		BEGIN(INITIAL);

<preprocessorIgnore><<EOF>>		BEGIN(INITIAL);




\n 					{ 
					/**
					* Newline. Increases line count and returns token NEWLINE
					*/
 						__fileStack->lineNum++; return NEWLINE; 
 					}

.                	{ 
					/**
					* Disregards input. DEBUG ONLY
					*/
						;
 					}	


<<EOF>>				{
					/**
					 * Reacts to the end of the file. If we are currently reading a 
					 * included file, closes it and pops the previous one from the stack.
					 * If we are reading a top level file, action stops the lexer.
					 */
						if ( --include_stack_ptr == -1 )
	                       	yyterminate();
		                else {
                     		yy_delete_buffer( YY_CURRENT_BUFFER );
                     		yy_switch_to_buffer( include_stack[include_stack_ptr] );
                     		__fileStack = __fileStack->previous;
                     		//yyin = __fileStack->file;
                     		std::cout << "Continuing reading " << __fileStack->fileName << std::endl;
                     	}
                 	}





%%

