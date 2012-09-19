#pragma once

#include "ASTNode.h"

class Identifier :
	public ASTNode
{
	std::string _identifier;
public:
	Identifier(void);

	void setIdentifier(std::string);

	virtual std::string toString();
	virtual ~Identifier(void);
};

