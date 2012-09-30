#include "Register.h"


Register::Register(void)
{
}

void Register::setRegister(std::string str)
{
	this->_register = str;
}

std::string Register::toString()
{
	return this->_register;
}


Register::~Register(void)
{
}
