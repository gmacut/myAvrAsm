#pragma once

#include "ASTNode.h"

class IntegerValue :
	public ASTNode
{
	int _integerValue;
public:
	IntegerValue(void);

	void setIntegerValue(int);

	virtual std::string toString();
	virtual ~IntegerValue(void);
};

