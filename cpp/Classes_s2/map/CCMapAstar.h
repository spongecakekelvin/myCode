#ifndef		__MAPASTAR_H__
#define		__MAPASTAR_H__

#include "cocos2d.h"
#include "MinHeap.h"

#include <vector>
#include <map>
using namespace std;

USING_NS_CC;

class MapAstar : public Ref{
public:
	MapAstar();
	~MapAstar();

	static MapAstar* getInstance();
	bool setMapdata(const char* mapData, int tileRow, int tileCol);
	bool init();
	bool findPath(int startx, int starty, int endx, int endy, int direction=8);
	bool getPath(vector<int>* vec);
	//void test(int direction);
private:
	MapNode* getMapNode(int x, int y);
	void insertNeighbourNode(MapNode* node, int direction);
	void insert4NeighbourNode(MapNode* node);
	void insert8NeighbourNode(MapNode* node);
	void insertNode(MapNode* parent, int x, int y, int direction);
	bool isCanWalk(int x, int y);
	bool isInOpenlist(MapNode* node);

	
private:
	static MapAstar* _instance;

	char* _mapData;
	int _mapDataLen;

	MapNode* _path;
	MinHeap* _openList;
	map<int, MapNode*> _openListMap;

	vector<MapNode*> _nodePool;
	map<int, MapNode*> _nodeMap;
	size_t _usedNodeNum;

	int _tileRow;
	int _tileCol;

	int endx;
	int endy;
	int bigDir;
};
#endif