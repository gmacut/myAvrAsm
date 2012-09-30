#pragma once

#include "ASTNode.h"

class Line :
	public ASTNode
{
	ASTNode* _child;
	ASTNode* _content;
public:
	Line(void);

	void setChild(ASTNode*);
	void setContent(ASTNode*);

	virtual std::string toString();
	virtual ~Line(void);
};

