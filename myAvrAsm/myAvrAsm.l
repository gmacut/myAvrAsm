%{
#pragma warning(disable: 4065)
#pragma warning(disable: 4083)
#pragma warning(disable: 4996)
#pragma warning(disable: 4273)


#include "InputFileRecord.h"
#include "instructions/index.h"

#include <iostream>
#include <cstring>
#include <cctype>

#include <string>
#include <map>
#include <vector>
#include <set>

using namespace std;

#include "myAvrAsm.tab.h"

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
						__fileStack->lineNum++;
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
						__fileStack->lineNum++;
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
						} else {
							while (endIndex <= yyleng && (yytext[endIndex] == ' ' || yytext[endIndex] == '\t'))
								endIndex++;
							if (endIndex <= yyleng){
								defineValues.push_back(std::string(yytext + endIndex, yyleng - endIndex));
							}
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
						__fileStack->lineNum++;
						BEGIN(INITIAL); 
					}

<preprocessorIgnore><<EOF>>		BEGIN(INITIAL);


#endif.*\n 			{ 
						__fileStack->lineNum++
						; // TODO: unput .* characters 
					}


(\n)|(\r\n)|(\r) 			{ 
								/**
								* Newline. Increases line count and returns token NEWLINE
								*/
			 					__fileStack->lineNum++; return NEWLINE; 
		 					}
^([ \t]*)(\n)|(\r\n)|(\r) 	{ 
								/**
								* Newline. Increases line count and returns token NEWLINE
								*/
			 					__fileStack->lineNum++; return NEWLINE; 
		 					}

.equ 				{
						return EQU;
					}

.def 				{
						return DEF;
					}

.device 			{
						return DEVICE;
					}

=					{
						return OP_EQUALS;
					}

,					{
						return OP_COMMA;
					}

^[_A-Za-z]+:		{
						Label *node = new Label;
						node->setLabel(std::string(yytext));
						yylval.node = node;
						return LABEL;
					}

^#pragma[ \t].*\n		{
						__fileStack->lineNum++;
						yytext[yyleng-1] = '\0';
						Pragma *node = new Pragma;
						node->setPragma(std::string(yytext+9));
						yylval.node = node;
						return PRAGMA;
					}

r[0-9]{1,2}			{
						Register *node = new Register;
						node->setRegister(std::string(yytext));
						yylval.node = node;
						return REGISTER_VALUE;
					}

[_A-Za-z][_A-Za-z0-9]*(\(.*\))? {
						char *yytextParsed;
						if ((yytextParsed = parseDefines(yytext)) == NULL){
							Identifier *node = new Identifier;
							node->setIdentifier(std::string(yytext));
							yylval.node = node;
							return IDENTIFIER;
						} else {
							for (int i = strlen(yytextParsed)-1; i >= 0; i--){
								unput((int)yytextParsed[i]);
							}
							free(yytextParsed);
						}
					}

0x[0-9a-f]+			{
						int temp;
						IntegerValue *node = new IntegerValue;
						sscanf(yytext, "%x", &temp);
						node->setIntegerValue(temp);
						yylval.node = node;
						return VALUE;
					}

[0-9]+				{
						int temp;
						IntegerValue *node = new IntegerValue;
						sscanf(yytext, "%d", &temp);
						node->setIntegerValue(temp);
						yylval.node = node;
						return VALUE;
					}

^([ \t]+)			{
						return WHITESPACE;
					}

([ \t])+ 			{ /* ignore whitespace not on the beginning of the line */; }

<<EOF>>				{
					/**
					 * Reacts to the end of the file. If we are currently reading a 
					 * included file, closes it and pops the previous one from the stack.
					 * If we are reading a top level file, action stops the lexer.
					 */
						if ( --include_stack_ptr == -1 ){
							return END_OF_FILE;
		                } else {
		            //    	std::cout << "Continuing reading " << std::endl;
                     		yy_delete_buffer( YY_CURRENT_BUFFER );
                     		yy_switch_to_buffer( include_stack[include_stack_ptr] );
                     		__fileStack = __fileStack->previous;
                    // 		std::cout << "Continuing reading " << __fileStack->fileName << std::endl;
                     	}
                 	}





%%

char *parseDefines(char *src){
	std::string parsed(src);
	bool wasChanged = false;
	for (std::map<std::string, std::vector<std::string> >::const_iterator it = __defines.begin();
			it != __defines.end();
			++it
		) {
		std::string define = it->first;
		std::vector<std::string> values = it->second;
		size_t found = parsed.find(define);
		if (found != std::string::npos){
			size_t positionOffset = found + define.length();
			size_t argumentStartIndex = 0;
			size_t argumentEndIndex = 0;
			if (positionOffset < parsed.length() && parsed[positionOffset] == '('){
				int openBracesCount = 1;
				argumentStartIndex = positionOffset + 1;
				while (1){
					positionOffset++;
					if (parsed[positionOffset] == '(') {
						openBracesCount++;
					}
					if (parsed[positionOffset] == ')') {
						openBracesCount--;
						if (openBracesCount == 0){
							argumentEndIndex = positionOffset;
							break;
						}
					}
				}
				std::string variable(parsed, argumentStartIndex, argumentEndIndex - argumentStartIndex);
				std::string temp;
				temp.append(parsed, 0, found);
				for (std::vector<std::string>::const_iterator it2 = values.begin();
					 it2 != values.end();
					 ++it2){
					temp.append(*it2);
					if (it2 != (--values.end())){
						temp.append(variable);
					}
				}
				temp.append(parsed, argumentEndIndex+1, parsed.length()-(argumentEndIndex+1));
				wasChanged = true;
				parsed = temp;
			} else {
				std::string temp;
				temp.append(parsed, 0, found);
				if (values.size() > 0) {
					temp.append(values[0]);
				}
				if (found + define.length() < parsed.length())
					temp.append(parsed, found + define.length(), parsed.length() - (found + define.length()) );
				wasChanged = true;
				parsed = temp;
			}
		}
	}
	if (wasChanged) {
		return strdup(parsed.c_str());
	} else { 
		return NULL;
	}
}
