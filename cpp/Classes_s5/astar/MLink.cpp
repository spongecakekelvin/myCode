#include "MLink.h"


MLink::MLink(MNode* node,double cost)
{
	this->cost =cost;
	this->node = node;
}


MLink::~MLink(void)
{
}
