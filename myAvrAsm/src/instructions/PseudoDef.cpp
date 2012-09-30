#include "PseudoDef.h"

#include <sstream>


PseudoDef::PseudoDef(void)
{
}

void PseudoDef::setIdentifier(Identifier *identifier)
{
	this->_identifier = identifier;
}

void PseudoDef::setRegister(Register *register_)
{
	this->_register = register_;
}

std::string PseudoDef::toString()
{
	std::stringstream ss;
	ss << ".DEF " << this->_identifier->toString() << " = " << this->_register->toString();
	return ss.str();
}


PseudoDef::~PseudoDef(void)
{
}
