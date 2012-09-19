#include "IntegerValue.h"
#include <sstream>


IntegerValue::IntegerValue(void)
{
}

void IntegerValue::setIntegerValue(int val)
{
	this->_integerValue = val;
}

std::string IntegerValue::toString()
{
	std::stringstream ss;
	ss << this->_integerValue;
	return ss.str();
}


IntegerValue::~IntegerValue(void)
{
}
