#include "Line.h"

#include <sstream>

Line::Line(void)
{
	this->_child = NULL;
	this->_content = NULL;
}

void Line::setChild(ASTNode * child)
{
	this->_child = child;
}

void Line::setContent(ASTNode* content){
	this->_content = content;
}


std::string Line::toString()
{
	std::stringstream ss;
	if (this->_child != NULL)
		ss << this->_child->toString() + "\n";
	if (this->_content != NULL)
		ss << this->_content->toString();
	return ss.str();
}


Line::~Line(void)
{
}
