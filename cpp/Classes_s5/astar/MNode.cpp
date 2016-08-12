#include "MNode.h"


MNode::MNode(int xvalue,int yvalue)
{
	this->x = xvalue;
	this->y = yvalue;
	this->walkable = true;
	this->initLink = false;
}

MNode::MNode()
{
	this->walkable = true;
	this->initLink = false;
}

MNode::~MNode(void)
{
}
