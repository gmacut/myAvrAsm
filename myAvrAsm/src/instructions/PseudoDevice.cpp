#include "PseudoDevice.h"


PseudoDevice::PseudoDevice(void)
{
}

void PseudoDevice::setDevice(std::string str)
{
	this->_device = str;
}

std::string PseudoDevice::toString()
{
	return "Device: " + this->_device;
}


PseudoDevice::~PseudoDevice(void)
{
}
