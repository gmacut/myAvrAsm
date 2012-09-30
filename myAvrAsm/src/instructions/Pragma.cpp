#include "Pragma.h"


Pragma::Pragma(void)
{
}

void Pragma::setPragma(std::string str)
{
	this->_pragma = str;
}

std::string Pragma::toString()
{
	return "Pragma: " + this->_pragma;
}


Pragma::~Pragma(void)
{
}
