#include "Identifier.h"


Identifier::Identifier(void)
{
}

void Identifier::setIdentifier(std::string str)
{
	this->_identifier = str;
}

std::string Identifier::toString()
{
	return this->_identifier;
}


Identifier::~Identifier(void)
{
}
