%{
#include "InputFileRecord.h"
#include "myAvrAsm.tab.h"

#include <iostream>
#include <cstring>

using namespace std;

#define YY_DECL extern int yylex()

extern InputFileRecord *FileStack;

// include files require lex to have separate buffers
#define MAX_INCLUDE_DEPTH 20
YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
int include_stack_ptr = 0;




%}



%option noyywrap
%x incl



%%



	
.[Ii][Nn][Cc][Ll][Uu][Dd][Ee][ \t]*\" 	BEGIN(incl);

<incl>[^ \t\n]+\"   { 
						
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
                 			std::cerr 	<< "[" << FileStack->fileName 
                 						<< ":" << FileStack->lineNum 
                 						<< "]: Unable to open include file " 
                 						<< newFile->fileName
                 						<< std::endl;
                 		} else {
                 			if ( include_stack_ptr >= MAX_INCLUDE_DEPTH ){
                     			std::cerr << "Includes nested too deep" << std::endl;
                     			exit( 1 );
                     		}
                     		include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;

                     		newFile->previous = FileStack;
                 			FileStack = newFile;
                 			yyin = FileStack->file;
                 			
                 			yy_switch_to_buffer( yy_create_buffer( yyin, YY_BUF_SIZE ) );

                 			std::cout << "Reading from included file:" << FileStack->fileName << std::endl;
                 		}     					
           		     	BEGIN(INITIAL);
                 	}
     
     
				
;.\n 				{ 
					/**
					 * Comments. They begin with ; and span to the end of the line
					 */	
						FileStack->lineNum++; 
					}


\n 					{ 
					/**
					* Newline. Increases line count and returns token NEWLINE
					*/
 						FileStack->lineNum++; return NEWLINE; 
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
                     		FileStack = FileStack->previous;
                     		//yyin = FileStack->file;
                     		std::cout << "Continuing reading " << FileStack->fileName << std::endl;
                     	}
                 	}





%%

