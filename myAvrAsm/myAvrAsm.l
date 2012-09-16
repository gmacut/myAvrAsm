%{
#pragma warning(disable: 4065)
#pragma warning(disable: 4083)
#pragma warning(disable: 4996)
#pragma warning(disable: 4273)
#include "InputFileRecord.h"
#include "myAvrAsm.tab.h"

#include <iostream>
#include <cstring>
#include <cctype>

#include <string>
#include <map>
#include <vector>
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
extern std::map<std::string, std::vector<std::string> > __defines;



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

char *parseDefines(char *src);

%}



%option noyywrap
%x incl
%x multilineComment
%x preprocessorIgnore



%%



	
[.#]include[ \t]*[\"<] {
							// This rule currently conflicts with LINE rule, which has preceedence
							// because of the longest match rule.
							// This is currently avoided by scanning LINE's yytext variable for 
							// 'include' string, and REJECTing LINE rule if 'include' is found.
							// That is a bad solution and should be avoided.
							//
							// TODO: This rule and the next one should be merged 
							BEGIN(incl);
						}


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
     
     
				
;.*\n 				{ 
					/**
					 * Comments that begin with ; and span to the end of the line
					 */	
					 	//std::cout << "Comment " << __fileStack->fileName << ": " << __fileStack->lineNum << std::endl;
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
						int startIndex = 7;
						while ( isspace( yytext[startIndex] )) startIndex++;

						int endIndex = startIndex;
						while ( isalnum( yytext[endIndex] ) || yytext[endIndex] == '_') endIndex++;
						
						std::string key(yytext + startIndex, endIndex - startIndex);

						std::vector<std::string> defineValues;

						if ( yytext[endIndex] == '(' ) {
							int fragmentStartIndex = endIndex;
							int fragmentEndIndex = fragmentStartIndex;
							while ( yytext[fragmentEndIndex++] != ')' );
							char *variableName = new char[fragmentEndIndex - fragmentStartIndex];
							strncpy(variableName, &(yytext[fragmentStartIndex+1]), (fragmentEndIndex-1) - (fragmentStartIndex+1));
							variableName[(fragmentEndIndex-1) - (fragmentStartIndex+1)] = '\0';

							char *definition = new char[yyleng - fragmentEndIndex];
							strncpy(definition, &(yytext[fragmentEndIndex]), yyleng - fragmentEndIndex);
							definition[yyleng - fragmentEndIndex - 1] = '\0';

							char *unprocessedDefinition = definition;

							while (1){
								char *variable = strstr(unprocessedDefinition, variableName);
								if (variable == NULL){
									defineValues.push_back(std::string(unprocessedDefinition));
									break;
								}
								defineValues.push_back(std::string(unprocessedDefinition, variable - unprocessedDefinition));
								unprocessedDefinition += (variable - unprocessedDefinition) + strlen(variableName);
							}
							
							for (std::vector<std::string>::const_iterator it = defineValues.begin();
								 it != defineValues.end();
								 ++it){
							}
							free(variableName);
							free(definition);
						}
						__defines[key] = defineValues;
						
					}

#ifdef.*\n 			{
						__fileStack->lineNum++;
						int startIndex = 6;
						while ( isspace( yytext[startIndex] )) startIndex++;

						int endIndex = startIndex;
						while ( isalnum( yytext[endIndex] ) || yytext[endIndex] == '_') endIndex++;
						
						std::string key(yytext + startIndex, endIndex - startIndex);

						if (__defines.find(key) == __defines.end()){
							BEGIN(preprocessorIgnore);
						}
					} 	

#ifndef.*\n 		{
						__fileStack->lineNum++;
						int startIndex = 7;
						while ( isspace( yytext[startIndex] )) startIndex++;

						int endIndex = startIndex;
						while ( isalnum( yytext[endIndex] ) || yytext[endIndex] == '_') endIndex++;
						
						std::string key(yytext + startIndex, endIndex - startIndex);

						if (__defines.find(key) != __defines.end()){
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

<preprocessorIgnore>\n  { __fileStack->lineNum++; }

<preprocessorIgnore>#endif.*\n 	{ 	
						BEGIN(INITIAL); 
					}

<preprocessorIgnore><<EOF>>		BEGIN(INITIAL);


#endif.*\n 			{ 
						; // TODO: unput .* characters 
					}


\n 					{ 
					/**
					* Newline. Increases line count and returns token NEWLINE
					*/
 						__fileStack->lineNum++; return NEWLINE; 
 					}

.*					{
						//std::cout << "LINE " << __fileStack->lineNum << ": " << yytext << std::endl;
						if (strstr(yytext, "include") == NULL && strstr(yytext, "#endif") == NULL) {
							char *yytextParsed;
							if ((yytextParsed = parseDefines(yytext)) == NULL){
								
								// Very ugly way of stripping comments. Really should be handled differently
								// TODO: Leave this to lexer
								for (int i = 0; i < yyleng; i++)
									if (yytext[i] == ';')
										yytext[i] = '\0';
								yylval.sval = yytext;
								yyleng = strlen(yytext);

								return LINE;
							} else {
								for (int i = strlen(yytextParsed)-1; i >= 0; i--){
									unput(yytextParsed[i]);
								}
								free(yytextParsed);
							}
						} else {
							REJECT;
						}
					}


<<EOF>>				{
					/**
					 * Reacts to the end of the file. If we are currently reading a 
					 * included file, closes it and pops the previous one from the stack.
					 * If we are reading a top level file, action stops the lexer.
					 */
						if ( --include_stack_ptr == -1 ){
							return END_OF_FILE;
		                } else {
		                	std::cout << "Continuing reading " << std::endl;
                     		yy_delete_buffer( YY_CURRENT_BUFFER );
                     		yy_switch_to_buffer( include_stack[include_stack_ptr] );
                     		__fileStack = __fileStack->previous;
                     		std::cout << "Continuing reading " << __fileStack->fileName << std::endl;
                     	}
                 	}





%%

char *parseDefines(char *src){
	std::string parsed(src);
	//std::cout << parsed << std::endl;
	bool wasChanged = false;
	for (std::map<std::string, std::vector<std::string> >::const_iterator it = __defines.begin();
			it != __defines.end();
			++it
		) {
		std::string define = it->first;
		std::vector<std::string> values = it->second;

		size_t found = parsed.find(define);
		if (found != std::string::npos){
			int openBracesCount = 0;
			int positionOffset = 0;
			int argumentStartIndex = 0;
			int argumentEndIndex = 0;
			while (1){
				positionOffset++;
				if (parsed[positionOffset] == '(') {
					openBracesCount++;
					if (openBracesCount == 1){
						argumentStartIndex = positionOffset;
					}
				}
				if (parsed[positionOffset] == ')') {
					openBracesCount--;
					if (openBracesCount == 0){
						argumentEndIndex = positionOffset;
						break;
					}
				}
			}
			std::string variable(parsed, argumentStartIndex+1, (argumentEndIndex) - (argumentStartIndex+1));
			std::string temp;
			temp.append(parsed, 0, found);
	//		std::cout << "ROOT: " << temp << std::endl;
			for (std::vector<std::string>::const_iterator it2 = values.begin();
				 it2 != values.end();
				 ++it2){
				temp.append(*it2);
	//			std::cout << "Appending " << *it2 << std::endl;
				if (it2 != (--values.end())){
	//				std::cout << "Appending variable" << variable << std::endl;
					temp.append(variable);
				}
			}
			temp.append(parsed, argumentEndIndex+1, parsed.length()-(argumentEndIndex+1));
	//		std::cout << "STEP: " << temp << std::endl;
			wasChanged = true;
			parsed = temp;
		}
	}
	if (wasChanged) {
		//std::cout << parsed << std::endl;
	//	std::cout << "RETURNING" << std::endl;
		return strdup(parsed.c_str());
	} else { 
		return NULL;
	}
}
