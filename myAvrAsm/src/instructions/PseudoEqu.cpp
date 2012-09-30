#include "PseudoEqu.h"

#include <sstream>

PseudoEqu::PseudoEqu(void)
{
	this->_left = NULL;
	this->_rightIdentifier = NULL;
	this->_rightValue = NULL;
	this->_resolved = false;
}

void PseudoEqu::setLeftIdentifier(Identifier * identifier)
{
	this->_left = identifier;
}


void PseudoEqu::setRightIdentifier(Identifier * identifier)
{
	this->_rightIdentifier = identifier;
	this->_resolved = false;
}


void PseudoEqu::setRightValue(IntegerValue * value)
{
	this->_rightValue = value;
	this->_resolved = true;
}

void PseudoEqu::setRightSide(ASTNode *node)
{
	Identifier *identifier = dynamic_cast<Identifier*>(node);
	if (identifier != NULL){
		this->setRightIdentifier(identifier);
		return;
	}
	IntegerValue *value = dynamic_cast<IntegerValue*>(node);
	if (value != NULL){
		this->setRightValue(value);
		return;
	}
}

bool PseudoEqu::isResolved()
{
	return this->_resolved;
}

std::string PseudoEqu::toString()
{
	std::stringstream ss;
	ss << ".EQU " << this->_left->toString() << " = ";
	if (this->_resolved)
		ss << this->_rightValue->toString();
	else 
		ss << this->_rightIdentifier->toString();
	return ss.str();
}


PseudoEqu::~PseudoEqu(void)
{
}
