#pragma once

#include "ASTNode.h"
#include "Identifier.h"
#include "Register.h"

class PseudoDef :
	public ASTNode
{
	Identifier *_identifier;
	Register *_register;
public:
	PseudoDef(void);

	void setIdentifier(Identifier *);
	void setRegister(Register *);

	virtual std::string toString();
	virtual ~PseudoDef(void);
};

