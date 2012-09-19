#pragma once

#include "ASTNode.h"

class Label :
	public ASTNode
{
	std::string _label;
public:
	Label(void);

	void setLabel(std::string);

	virtual std::string toString();
	virtual ~Label(void);
};

