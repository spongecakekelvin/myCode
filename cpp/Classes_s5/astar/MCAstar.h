/**
*开发者：成畅
* 修改时间:
*/
/*
                   _ooOoo_
                  o8888888o
                  88" . "88
                  (| -_- |)
                  O\  =  /O
               ____/`---'\____
             .'  \\|     |//  `.
            /  \\|||  :  |||//  \
           /  _||||| -:- |||||-  \
           |   | \\\  -  /// |   |
           | \_|  ''\---/''  |   |
           \  .-\__  `-`  ___/-. /
         ___`. .'  /--.--\  `. . __
      ."" '<  `.___\_<|>_/___.'  >'"".
     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
     \  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
                   `=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         佛祖保佑       永无BUG
*/
/* ****************************************************************************/
#ifndef _C_CCARPG_ASTAR_H_
#define _C_CCARPG_ASTAR_H_
#include "cocos2d.h"
#include <vector>
#include "MapGrid.h"
class MCAstar  : public cocos2d::Ref
{
public:
	~MCAstar(void);
	static MCAstar* getInstance();
	void updateMap(MNode** allnodes,unsigned short  row,unsigned short  col);
	void findPath(int startx,int starty,int endx,int endy,char **result,int *resultlen,int *originlen,bool needBlock,int maxlen);
	void setWalkable(int x,int y,bool value);
	bool isWalkable(int x,int y);
	MNode* getEndNode(int x,int y, int cycle);

private:
	////
	MNode* endNode;
	MNode* startNode;
	//private var _path:Array;
	//private var heuristic:Function;
	int nowversion;
	MapGrid grid;
	void resetHeap();
	bool justMin(MNode* ob1,MNode* ob2);
	int getHeapLenght();
	void buildPath(MNode* node,char **result,int *resultlen,int *originlen,int maxlen);
	void ins(MNode* ob);
	MNode* pop();
	double euclidian(MNode* node);
	double diagonal(MNode* node);
	int getDir(int startx,int starty,int endx,int endy);
	void  search(bool needBlock,char **result,int *resultlen,int *originlen,int maxlen);
	void optimizePath();
	std::vector<MNode*> heapNodes;
};

#endif

