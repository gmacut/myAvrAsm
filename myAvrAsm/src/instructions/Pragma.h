#pragma once

#include "ASTNode.h"

class Pragma :
	public ASTNode
{
	std::string _pragma;
public:
	Pragma(void);

	void setPragma(std::string);

	virtual std::string toString();
	virtual ~Pragma(void);
};

