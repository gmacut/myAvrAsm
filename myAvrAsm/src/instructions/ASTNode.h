#pragma once
#include <string>

class ASTNode
{
public:
	ASTNode(void);
	
	virtual std::string toString() = 0;
	
	virtual ~ASTNode(void);
};

