#include <iostream>
#include <cstdio>

#include <getopt.h>
#include <stdlib.h>

#include <string>
#include <set>

#include "InputFileRecord.h"

#include "myAvrAsm.tab.h"

// stuff from flex that bison needs to know about:
extern int yylex();
extern int yyparse();
extern FILE *yyin;

//extern struct InputFileRecord* FileStack;

using namespace std;



/**********************************************
					GLOBALS
**********************************************/
/**
 * Number of input files
 */
int __numberOfInputFiles;

/**
 * Pointer to an array of input file names.
 * Should contain __numberOfInputFiles file
 * names.
 */
char **__inputFileNames;


InputFileRecord *__fileStack;

std::set<std::string> __defines;



/***********************************************
					PROTOTYPES
***********************************************/
/**
 * Reads program input parameters and fills 
 * global configuration data.
 * 
 * @param argc command line arguments count, size of argv 
 *			array
 * @param argv char* array with parameters. First one
 *			contains call name for the program, others
 *			are command line parameters
 * @param envp char* array with environment variables. 
 			Should be used with gentv("NAME") call from 
 			stdlib.h			
 * @return 0 when successfull, -1 on error
 */
int readInputParameters(int argc, char* argv[], char*envp[]);

/**
 * Prints usage details on stderr
 */
void printUsage();



/*******************	***********************

					MAIN

********************	**********************/

int main(int argc, char* argv[], char* envp[]) {
	int er = 0;
	er = readInputParameters(argc, argv, envp);
	if (er){
		printUsage();
		exit(-1);
	}

	for (int i = 0; i < __numberOfInputFiles; i++ ){
		std::cout << __inputFileNames[i] << std::endl;
		FILE *input = fopen(__inputFileNames[i], "r");
		if (!input) {
			std::cerr << "Couldn't open " << __inputFileNames[i] << " file!";
			exit(-1);
		}
		yyin = input;
		__fileStack = new InputFileRecord;
		__fileStack->lineNum = 1;
		__fileStack->fileName = __inputFileNames[i];
		__fileStack->file = input;
		__fileStack->previous = NULL;
		do {
			yyparse();
		} while(!feof(yyin));
		std::cout << "Read " << __fileStack->lineNum << " lines from " << __fileStack->fileName << std::endl;
 	}

 	return 0;
}



/*************************************************************
						DEFINITIONS
*************************************************************/
int readInputParameters(int argc, char* argv[], char*envp[]){
	__numberOfInputFiles = argc - 1;
	__inputFileNames = argv + 1;
	if (__numberOfInputFiles > 0)
		return 0;
	else
		return -1;
}

void printUsage(){
	std::cerr 	<< "Program should be called with at lest one "
				<< "argument: name of input file" << std::endl
				<< "\tExample: " << std::endl
				<< "\t\tmyAvrAsm program.asm" << std::endl; 
}