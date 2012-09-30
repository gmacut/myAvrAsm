#pragma once

#include "ASTNode.h"
#include "Identifier.h"
#include "IntegerValue.h"

class PseudoEqu :
	public ASTNode
{
	Identifier *_left;
	Identifier *_rightIdentifier;
	IntegerValue *_rightValue;
	bool _resolved;
public:
	PseudoEqu(void);

	void setLeftIdentifier(Identifier *);
	void setRightIdentifier(Identifier *);
	void setRightValue(IntegerValue *);

	virtual void setRightSide(ASTNode *);

	bool isResolved();

	virtual std::string toString();
	virtual ~PseudoEqu(void);
};

