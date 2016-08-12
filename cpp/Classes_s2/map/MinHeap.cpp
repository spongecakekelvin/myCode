#include "MinHeap.h"
#include <iostream>

MinHeap::MinHeap(size_t size)
{
	_heapArray.reserve(size);
}

MinHeap::~MinHeap()
{

}
int MinHeap::parent(int pos)
{
	return (pos-1)/2;
}

void MinHeap::shiftDown(int pos, size_t currentSize)
{
	size_t i = pos;
	size_t j = 2*i+1;
	MapNode* tmp = _heapArray[i];
	//int currentSize = _heapArray.size();
	while(j < currentSize){
		if((j<currentSize-1) && (*_heapArray[j+1] < *_heapArray[j]))
			j++;

		if(*_heapArray[j] < *tmp){
			_heapArray[i] = _heapArray[j];
			_heapArray[i]->index = i;
			i = j;
			j = 2*j+1;
		}else
		{
			break;
		}
	}
	_heapArray[i] = tmp;
	_heapArray[i]->index = i;
}

void MinHeap::shiftUp(int pos)
{
	int tmppos = pos;
	MapNode* tmp = _heapArray[pos];

	while((tmppos>0) && (*tmp < *_heapArray[parent(tmppos)])){
		_heapArray[tmppos] = _heapArray[parent(tmppos)];
		_heapArray[tmppos]->index = tmppos;
		tmppos = parent(tmppos);
	}
	_heapArray[tmppos] = tmp;
	_heapArray[tmppos]->index = tmppos;
}

void MinHeap::push(MapNode* node)
{
	_heapArray.push_back(node);
	shiftUp(_heapArray.size()-1);
}

MapNode* MinHeap::pop()
{
	int s = _heapArray.size();
	if(s == 0)
		return nullptr;
	MapNode* ret = _heapArray[0];

	MapNode* tmpnode = _heapArray.back();
	_heapArray[0] = tmpnode;
	_heapArray[0]->index = 0;
	_heapArray.pop_back();
	s = s-1;
	if(s>1){
		shiftDown(0, s);
	}
	return ret;
	
}

#include <iostream>
using namespace std;

bool MinHeap::remove(int pos)
{
	//cout << "remove :" << pos << " size:" << _heapArray.size() <<endl; 
	size_t size = _heapArray.size();
	if(pos<0 || pos>=size)
		return false;

	if(pos == size-1){
		_heapArray.pop_back();
		return true;
	}
	//MapNode* tmp = _heapArray[pos];
	_heapArray[pos] = _heapArray.back();
	_heapArray[pos]->index = pos;
	_heapArray.pop_back();
	shiftUp(pos);
	shiftDown(pos,size-1);
	return true;
}

int MinHeap::size()
{
	return _heapArray.size();
}

void MinHeap::clear()
{
	_heapArray.clear();
}

void MinHeap::print()
{
	std::cout<<"minheap size:"<< _heapArray.size() << std::endl;
	MapNode*tmp = nullptr;
	//while(tmp = pop()){
	//	std::cout<< tmp->x << std::endl;
	//}

	for(auto i : _heapArray)
	{
		std::cout << i->x << " " << i->index <<std::endl;
	}
}