#ifndef _INPUT_FILE_RECORD_H
#define _INPUT_FILE_RECORD_H

#include <stdio.h>

struct InputFileRecord{
	int lineNum;
	char *fileName;
	struct InputFileRecord *previous;
	FILE *file;
};

#endif