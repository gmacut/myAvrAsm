#include "Label.h"


Label::Label(void)
{
}

void Label::setLabel(std::string str)
{
	this->_label = str;
}

std::string Label::toString()
{
	return "Label: " + this->_label;
}


Label::~Label(void)
{
}
