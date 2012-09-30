#ifndef _INPUT_FILE_RECORD_H
#define _INPUT_FILE_RECORD_H

#include <stdio.h>

/**
 * Encapsulates input file information. Lexer
 * puts these records on stack __FileStack 
 * (defined in myAvrAsm.cpp). Top is reachable
 * through that pointer, records below are 
 * reachable through member pointer previous
 */
struct InputFileRecord{
    /**
     * Line currently being read. As line numbers
     * beging with 1, should be initialized to 1 
     * during structure creation
     */
    int lineNum;

    /**
     * Physical file name of the file
     */
    char *fileName;

    /**
     * Poiter to record below this one on stack
     */
    struct InputFileRecord *previous;

    /**
     * Input FILE
     */
    FILE *file;
};

#endif