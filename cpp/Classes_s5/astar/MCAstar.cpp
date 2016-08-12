#include "MCAstar.h"
#include "MLink.h"
#include <vector>

#define  DIAG_COST M_SQRT2

extern long getTimer();  

MCAstar* MCAstar::getInstance()
{
	static MCAstar* instance = NULL;
	if(instance == NULL)
		{
			instance = new MCAstar();
			instance->nowversion = 1;
			instance->resetHeap();
	}
	return instance;
}

void MCAstar::updateMap(MNode** allnodes,unsigned short  row,unsigned short  col)
{
	this->grid.setNodes(allnodes,  row, col);
	this->nowversion = 1;
}


MNode* MCAstar::getEndNode(int x,int y, int cycle)
{
	MNode* node = this->grid.getNode(x, y);
	if (node)
	{
		return node;
	}
	else
	{
		for (int i=1; i <= cycle; i++)
		{
			for (int k=x - i; k <= x + i; k++)
			{
				for (int j=y - i; j <= y + i; j++)
				{
					node = this->grid.getNode(k, j);
					if (node)
					{
						return node;
					}
				}
			}
		}
	}
	return NULL;
}

void MCAstar::findPath(int startx,int starty,int endx,int endy,char **result,int *resultlen,int *originlen,bool needBlock,int maxlen=999999)
{
	long lasttt = getTimer();
	this->startNode = this->grid.getNode(startx,starty);
    this->endNode = this->getEndNode(endx,endy,5);
	if(this->startNode==NULL || this->endNode == NULL)
	{
		*resultlen = 0;
		*result = NULL;
		return;
	}


	 //CCLOG("findPath = %d %d %d %d",this->startNode->x,this->startNode->y,this->endNode->x,this->endNode->y);
	this->nowversion++;
	this->resetHeap();
	this->startNode->g = 0;

	this->search(needBlock,result,resultlen,originlen,maxlen*2);
	
	//CCLOG("findpath need time = %d",(getTimer()-lasttt));

}

void  MCAstar::search(bool needBlock,char **result,int *resultlen,int *originlen,int maxlen=999999)
{
	MNode*  node=this->startNode;
	MLink* linkvo;
	//int countlen = 0;
	bool endnodewalkable = this->endNode->walkable;
	this->endNode->walkable = true;
	this->grid.initNodeLink(this->startNode);
	node->version=nowversion;
	while (node != this->endNode)
	{

		int len=node->links.size();
		for (int i=0; i < len; i++)
		{
			linkvo = node->links[i];
			MNode* test= linkvo->node;
			if (needBlock&&!test->walkable)
			{
				continue;
			}
			this->grid.initNodeLink(test);
			double g=node->g + linkvo->cost;
			double h=this->euclidian(test);
			double f =g + h;
			if (test->version == nowversion)
			{
				if (test->f > f)
				{
					test->f=f;
					test->g=g;
					test->h=h;
					test->parent=node;
				}
			}
			else
			{ 
				test->f=f;
				test->g=g;
				test->h=h;
				test->parent=node;
				this->ins(test);
				test->version=nowversion;
			}

		}
		if (this->getHeapLenght()== 1)
		{
			*resultlen = 0;
			*result = NULL;
			this->endNode->walkable = endnodewalkable;
			return;
		}

		node=this->pop();

		//countlen++;

		//if(countlen>maxlen)
		//{
		//	this->buildPath(node,result,resultlen);
		//	break;
		//	
		//}
	}
	this->endNode->walkable = endnodewalkable;
	this->buildPath(this->endNode,result,resultlen,originlen,maxlen);
}

int MCAstar::getDir(int startx,int starty,int endx,int endy)
{
	if((startx==endx) &&(starty!=endy) )
	{
		return 0;
	}
	else if((startx!=endx) &&(starty==endy) )
	{
		return 2;
	}
	else if(((startx<endx) &&(starty>endy)) ||((startx>endx) &&(starty<endy)))
	{
		return 1;
	}
	else if(((startx<endx) &&(starty<endy)) ||((startx>endx) &&(starty>endy)))
	{
		return 3;
	}

	return -1;
}
void MCAstar::buildPath(MNode* nodeStart,char **result,int *resultlen,int *originlen,int maxlen=999999)
{
	std::vector<char> vresult;
	//_path=[];
	int allcount = 1;
	MNode* node = nodeStart;
	vresult.push_back(node->x);
	vresult.push_back(node->y);
	//CCLOG("%d %d",node->parent==NULL,node==NULL);
	//CCLOG("%d",node->x);
	//CCLOG("%d",node->y);
	//CCLOG("%d",node->parent->x);
	//CCLOG("%d",node->parent->y);
	if(node != this->startNode)
	{
		int dirTemp = this->getDir(node->x,node->y,node->parent->x,node->parent->y);
		int dircurrent = 0;
		while (node->parent != this->startNode)
		{
			node=node->parent;
			dircurrent=  this->getDir(node->x,node->y,node->parent->x,node->parent->y);
			//if(dirTemp!=dircurrent)
			{
				vresult.push_back(node->x);
				vresult.push_back(node->y);
				dirTemp = dircurrent;
			}
			allcount++;

		}
    }

		//for (auto it = vresult.begin(); it != vresult.end(); it++)
		//{
		//	CCLOG("%d",*it);
		//}
	
	int plen =  vresult.size();
	 //CCLOG("buildpath = %d",plen);
	//for (int i=0;i<plen;i++)
	//{
	//	  unsigned char gg = vresult[i];
	//	 CCLOG("buildpath = %d",gg);
	//}
	if(plen<=maxlen)
	{
	*resultlen = plen;
	*originlen = allcount;
	//*result = &vresult.at(0);

	char *p = new char[plen+1];
	*result = p;
	p[plen]=0;
	copy(vresult.begin(),vresult.end(), p);
    }
	else
	{
		*resultlen = maxlen;
		*originlen = maxlen;
	//*result = &vresult.at(0);

	char *p = new char[maxlen+1];
	*result = p;
	p[maxlen]=0;
	auto it = vresult.begin();
	it+=plen-maxlen;
	copy(it,vresult.end(), p);
	}
}


void MCAstar::setWalkable(int x,int y,bool value)
{
	MNode* node = this->grid.getNode(x,y);
	if(node)
	{
        node->walkable = value;
	}
}

bool MCAstar::isWalkable(int x,int y)
{
	MNode* node = this->grid.getNode(x,y);
	if(!node)
	{
		return false;
	}

	return node->walkable;
}

void MCAstar::optimizePath()
{
	//			_path=[];
	//			var node:Node=manulNode;
	//			_path.push(node.pt);

}

//		public function manhattan(node:Node):Number
//		{
//			return Math.max(Math.abs(node.x - _endNode.x) + Math.abs(node.y - _endNode.y));
//			//return Math.abs(node.x - _endNode.x) + Math.abs(node.y - _endNode.y);
//		}
//
//		public function manhattan2(node:Node):Number
//		{
//			var dx:Number=Math.abs(node.x - _endNode.x);
//			var dy:Number=Math.abs(node.y - _endNode.y);
//			return dx + dy + Math.abs(dx - dy) / 1000;
//		}
//
double MCAstar::euclidian(MNode* node)
{
	double dx=node->x - this->endNode->x;
	double dy=node->y - this->endNode->y;
	return sqrt(dx * dx + dy * dy);
}
//
//		private var TwoOneTwoZero:Number=2 * Math.cos(Math.PI / 3);
//
//		public function chineseCheckersEuclidian2(node:Node):Number
//		{
//			var y:int=node.y / TwoOneTwoZero;
//			var x:int=node.x + node.y / 2;
//			var dx:Number=x - _endNode.x - _endNode.y / 2;
//			var dy:Number=y - _endNode.y / TwoOneTwoZero;
//			return sqrt(dx * dx + dy * dy);
//		}
//
//
//		public function euclidian2(node:Node):Number
//		{
//			var dx:Number=node.x - _endNode.x;
//			var dy:Number=node.y - _endNode.y;
//			return dx * dx + dy * dy;
//		}
//
double MCAstar::diagonal(MNode* node)
{
	double dx=abs(node->x - this->endNode->x);
	double dy=abs(node->y -this->endNode->y);
	double diag;
	if(dx>dy)
	{
		diag = dy;
	}
	else
	{
		diag = dx;
	}
	double straight=dx + dy;
	return DIAG_COST * diag +  (straight - 2 * diag);
}


void MCAstar::resetHeap()
{
	this->heapNodes.clear();
	this->heapNodes.push_back(NULL);

}

bool MCAstar::justMin(MNode* ob1,MNode* ob2)
{
	return ob1->f < ob2->f;

}

int MCAstar::getHeapLenght()
{
	return this->heapNodes.size();

}

//void MCAstar::ins(MNode* ob)
//{
//	int index = this->getHeapLenght();
//	this->heapNodes.push_back(ob);
//	int halfIndex = index >> 1;
//	while (index> 1 && this->justMin(this->heapNodes.at(index),this->heapNodes.at(halfIndex)))
//	{
//		MNode* tempNode=this->heapNodes.at(index);
//		this->heapNodes.at(index)=this->heapNodes.at(halfIndex);
//		this->heapNodes.at(halfIndex)=tempNode;
//		index=halfIndex;
//		halfIndex=index >> 1;
//	}
//}

void MCAstar::ins(MNode* ob)
{
	int index = this->heapNodes.size();
	//CCLOG("ob = %d %d",ob->x,ob->y);
	this->heapNodes.push_back(ob);
	int halfIndex = index >> 1;
	while (index> 1 && this->justMin(this->heapNodes[index],this->heapNodes[halfIndex]))
	{
		MNode* tempNode=this->heapNodes[index];
		this->heapNodes[index]=this->heapNodes[halfIndex];
		this->heapNodes[halfIndex]=tempNode;
		index=halfIndex;
		halfIndex=index >> 1;
	}
	 //index = this->heapNodes.size();
	 //for (int i=0;i<index;i++)
	 //{
		// ob = this->heapNodes[i];
		// if (ob)
		// {
		//	 CCLOG("heapNodes = %d %d",ob->x,ob->y);
		// }
	 //}
	

}



MNode* MCAstar::pop()
{
	MNode* ob=this->heapNodes[1];
	this->heapNodes[1]=this->heapNodes[heapNodes.size() - 1];
	this->heapNodes.pop_back();
	int index = 1;
	int len =this->heapNodes.size();
	int multiplyIndex1=index << 1;
	int multiplyIndex2=multiplyIndex1 + 1;
	int minp;
	while (multiplyIndex1 < len)
	{
		if (multiplyIndex2 < len)
		{
			 minp=justMin(this->heapNodes[multiplyIndex2], this->heapNodes[multiplyIndex1]) ? multiplyIndex2 : multiplyIndex1;
		}
		else
		{
			minp=multiplyIndex1;
		}
		if (justMin(this->heapNodes[minp], this->heapNodes[index]))
		{
			MNode* temp=this->heapNodes[index];
			this->heapNodes[index]=this->heapNodes[minp];
			this->heapNodes[minp]=temp;
			index=minp;
			multiplyIndex1=index << 1;
			multiplyIndex2=multiplyIndex1 + 1;
		}
		else
		{
			break;
		}
	}

	//CCLOG("pop ob = %d %d",ob->x,ob->y);
	return ob;
}

MCAstar::~MCAstar(void)
{
}
