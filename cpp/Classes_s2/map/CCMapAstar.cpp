#include "CCMapAstar.h"

const int default_size = 64*1024;

MapAstar* MapAstar::_instance = nullptr;

static int countH(int startx, int starty, int endx, int endy)
{
	int x_dis = startx - endx;
	int y_dis = starty - endy;
	x_dis < 0 ? (x_dis = -x_dis) : 0;
	y_dis < 0 ? (y_dis = -y_dis) : 0;
	return sqrt(x_dis*x_dis + y_dis*y_dis) * 100;
}

///leftΪ1fangxiang
static int getCostG(int direction, int bigDir)
{
	//int i = direction & 0x01;
	//return i ? 10 : 140;
	int i = 0;

	if(direction == 2 || direction == 6){
		i = 100;
	}else if(direction == 4 || direction == 8){
		i = 200;
	}else{
		i = 112;
	}
	return i;
}

MapAstar* MapAstar::getInstance()
{
	if(_instance == nullptr){
		_instance = new MapAstar();
		if(!(_instance&&_instance->init())){
			CC_SAFE_DELETE(_instance);
		}
	}
	return _instance;	
}

MapAstar::MapAstar()
{
	_mapData = nullptr;
	_openList = nullptr;
	_path = nullptr;
	_usedNodeNum = 0;
	_mapDataLen = 0;
	_tileRow = 0;
	_tileCol = 0;
}

bool MapAstar::init()
{
	_mapData = new char[default_size];
	_openList = new MinHeap();

	if(_mapData && _openList){
		_nodePool.reserve(512);
		_mapDataLen = default_size;
		return true;
	}else {
		CC_SAFE_DELETE(_openList);
		CC_SAFE_DELETE_ARRAY(_mapData);
		return false;
	}
}

MapAstar::~MapAstar()
{
	CC_SAFE_DELETE(_openList);
	CC_SAFE_DELETE_ARRAY(_mapData);
	for(auto i : _nodePool){
		delete i;
	}
}

bool MapAstar::setMapdata(const char* mapData, int tileRow, int tileCol)
{
	int len = tileRow * tileCol;
	if(len > _mapDataLen){
		CC_SAFE_DELETE_ARRAY(_mapData);
		_mapData = new char[len];
		_mapDataLen = len;
		if(_mapData)
			return false;
	}
	memmove(_mapData, mapData, len);
	_tileRow = tileRow;
	_tileCol = tileCol;
	return true;
}

MapNode* MapAstar::getMapNode(int x, int y)
{
	int key = x * _tileCol + y;
	auto iter = _nodeMap.find(key);
	if(iter != _nodeMap.end())
		return iter->second;

	size_t size = _nodePool.size();
	if(size <= _usedNodeNum){
		MapNode* node = new MapNode();
		node->x = x;
		node->y = y;
		_nodePool.push_back(node);
		_usedNodeNum++;
		_nodeMap[key] = node;
		return node;
	}else{
		MapNode* node = _nodePool[_usedNodeNum++];
		node->reset();
		node->x = x;
		node->y = y;
		_nodeMap[key] = node;
		return node;
	}	
}

bool MapAstar::isCanWalk(int x, int y)
{
	int key = x * _tileCol + y;
	int c = _mapData[key];
	return c&0x01;
}

bool MapAstar::isInOpenlist(MapNode* node)
{
	auto iter = _openListMap.find(node->x * _tileCol + node->y);
	return iter != _openListMap.end();
}

void MapAstar::insertNode(MapNode* parent, int x, int y, int direction)
{
	if(x < 0 || y < 0 || x >= _tileRow || y >= _tileCol)
		return;
	if(!isCanWalk(x, y))
		return;
	
	MapNode* node = getMapNode(x, y);
	if(node->block)
		return;
	
	if(!isInOpenlist(node)){
		node->parent = parent;
		node->g = parent->g + getCostG(direction, bigDir);
		node->h = countH(x, y, endx, endy);
		node->f = node->g + node->h;
		_openList->push(node);
		_openListMap[x * _tileCol + y] = node;
	}else{
		int tmpg = parent->g + getCostG(direction, bigDir);
		int tmpH = countH(x, y, endx, endy);
		if((node->g + node->h) > (tmpg + tmpH)){
			_openList->remove(node->index);
			node->parent = parent;
			node->g = tmpg;
			node->h = tmpH;
			node->f = node->g + node->h;
			node->index = -1;
			_openList->push(node);
		}
	}	
}

void MapAstar::insert4NeighbourNode(MapNode* node)
{
	int x = node->x;
	int y = node->y;
	//left
	insertNode(node, x-1, y, 1);
	//right
	insertNode(node, x+1, y, 3);
	//up 
	insertNode(node, x, y+1, 5);
	//bottom
	insertNode(node, x, y-1, 7);
}

void MapAstar::insert8NeighbourNode(MapNode* node)
{
	int x = node->x;
	int y = node->y;
	//insert4NeighbourNode(node);

	if(bigDir == 2){
		insertNode(node, x-1, y+1, 2);
		insertNode(node, x-1, y-1, 8);
		insertNode(node, x-1, y, 1);

		insertNode(node, x+1, y+1, 4);	
		insertNode(node, x+1, y-1, 6);
		insertNode(node, x+1, y, 5);
		insertNode(node, x, y+1, 3);
		insertNode(node, x, y-1, 7);
	}else {
		insertNode(node, x+1, y+1, 4);	
		insertNode(node, x+1, y-1, 6);
		insertNode(node, x+1, y, 5);

		insertNode(node, x-1, y+1, 2);
		insertNode(node, x-1, y-1, 8);
		insertNode(node, x-1, y, 1);
		insertNode(node, x, y+1, 3);
		insertNode(node, x, y-1, 7);
	}
	
	
		
	

	
	
	
}

void MapAstar::insertNeighbourNode(MapNode* node, int direction)
{
	if (direction == 4)
		insert4NeighbourNode(node);
	else 
		insert8NeighbourNode(node);
}

bool MapAstar::findPath(int startx, int starty, int endx, int endy, int direction)
{
	this->endx = endx;
	this->endy = endy;
	_path = nullptr;

	_openList->clear();
	_openListMap.clear();
	_nodeMap.clear();
	_usedNodeNum = 0;

	if(startx == endx && starty == endy)
		return false;
	if(!isCanWalk(endx, endy))
		return false;

	if(startx < endx)
		bigDir = 2;
	else 
		bigDir = 6;
	///////
	MapNode* node = getMapNode(startx, starty);
	node->g = 0;
	node->h = countH(startx, starty, endx, endy);
	node->f = node->g + node->h;
	_openList->push(node);
	_openListMap[startx * _tileCol + starty] = node;

	MapNode* minNode = nullptr;
	bool isfind = false;

	while(_openList->size() > 0){
		minNode = _openList->pop();
		minNode->block = true;
		_openListMap.erase(minNode->x * _tileCol + minNode->y);

		if(minNode->x == endx && minNode->y == endy){
			isfind = true;
			break;
		}

		insertNeighbourNode(minNode, direction);
	}

	if(isfind){
		//CCLOG("isfind:%d\n", isfind);
		_path = minNode;
	}
	return isfind;
}

bool MapAstar::getPath(vector<int>* vec)
{
	while(_path){
		vec->push_back(_path->y);
		vec->push_back(_path->x);
		_path = _path->parent;
	}
	return true;
}
