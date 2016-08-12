#ifndef		__MAPNODE_H__
#define		__MAPNODE_H__

class MapNode{
public:
	MapNode();
	~MapNode(){};

	bool operator<(MapNode& node); 
	bool operator=(MapNode& node);
	void reset();
	bool block;
	short x;
	short y;
	short index;
	unsigned int g;
	unsigned int h;	
	unsigned int f;
	MapNode* parent;

};

#endif