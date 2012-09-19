#pragma once

#include "ASTNode.h"

class Register :
	public ASTNode
{
	std::string _register;
public:
	Register(void);

	void setRegister(std::string);

	virtual std::string toString();
	virtual ~Register(void);
};

