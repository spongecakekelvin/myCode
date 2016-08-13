#ifndef		__MINHEAP_H__
#define		__MINHEAP_H__

#include "MapNode.h"
#include <vector>
using namespace std;

class MinHeap {
public:
	MinHeap(size_t size=256);
	~MinHeap();

	void push(MapNode* node);
	MapNode* pop();
	bool remove(int pos);
	int size();
	void clear();

	void print();
private:
	void shiftDown(int pos, size_t currentSize);
	void shiftUp(int pos);
	int parent(int pos);
	vector<MapNode*> _heapArray;
};
#endif