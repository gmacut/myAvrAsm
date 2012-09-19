#pragma once

#include "ASTNode.h"

class PseudoDevice :
	public ASTNode
{
	std::string _device;
public:
	PseudoDevice(void);

	void setDevice(std::string);

	virtual std::string toString();
	virtual ~PseudoDevice(void);
};

