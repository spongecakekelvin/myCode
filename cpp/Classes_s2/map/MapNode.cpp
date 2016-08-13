#include "MapNode.h"

MapNode::MapNode()
{
	x=0;
	y=0;
	g=0;
	h=0;
	f=0;
	index = -1;
	block = false;
	parent = nullptr;
}

bool MapNode::operator<(MapNode& node)
{
	//return (g+h) < (node.g+node.h);
	return f < node.f;
}

bool MapNode::operator=(MapNode& node)
{
	return (x == node.x && y == node.y);
}

void MapNode::reset()
{
	x=0;
	y=0;
	g=0;
	h=0;
	f=0;
	block = false;
	parent = nullptr;
}