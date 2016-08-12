#include "MapGrid.h"
#include <math.h>
#include "MLink.h"

#define  XCOST 2
#define  YCOST 1
#define  STRAIGHT_COST  1.118034

//double MapGrid::STRAIGHT_COST = sqrt(1.25);

//MapGrid::MapGrid(ArpgMapData *mapdata)
//{
//	this->updateNodes(mapdata);
//}
//
//
//MapGrid::Reset(ArpgMapData *mapdata)
//{
//	delete[] nodes;
//	this->updateNodes(mapdata);
//}
//
//void MapGrid::updateNodes(ArpgMapData *mapdata)
//{
//
//
//}

MapGrid::MapGrid()
{
}

void MapGrid::setNodes(MNode** allnodes,unsigned short  row,unsigned short  col)
{
	this->nodes = allnodes;
	this->nodeLen = row*col;
	this->row = row;
	this->col = col;
}

void MapGrid::initNodeLink(MNode *node)
{
	if (node->initLink)
		return;
	short startX=node->x - 1;
	short endX=node->x + 1;
	short startY=node->y - 1;
	short endY=node->y + 1;

	startX = startX >= 0 ? startX:0;
	startY = startY >= 0 ? startY:0;
	endX = endX>this->row ? this->row:endX;
	endY = endY>this->col ? this->col:endY;
	node->links.clear();
	for (int i=startX; i <= endX; i++)
	{
		for (int j=startY; j <= endY; j++)
		{

			MNode* test=this->getNode(i, j);
			if (test == NULL || test == node)
			{ 
				continue;
			}
			double cost=STRAIGHT_COST; 
			if ((node->x - test->x == 1 && node->y - test->y == 1) || (node->x - test->x == -1 && node->y - test->y == -1))
			{
				cost=YCOST;
			}
			else if ((node->x - test->x == -1 && node->y - test->y == 1) || (node->x - test->x == 1 && node->y - test->y == -1))
			{
				cost=XCOST;
			}
			node->links.push_back(new MLink(test, cost));
		}
	}
	node->initLink=true;
}

MNode*  MapGrid::getNode(int x,int y)
{
   unsigned short index = x*this->col + y;
   if(index<this->nodeLen)
   {
     return this->nodes[index];
   }
   return NULL;

}





MapGrid::~MapGrid(void)
{
	for(int i=0; i<this->nodeLen; i++)  
	{
		if(this->nodes[i])
		   delete this->nodes[i];  
	}
	delete[] this->nodes;  
}
