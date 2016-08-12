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


#ifndef _C_CCARPG_MAPGRID_H_
#define _C_CCARPG_MAPGRID_H_

#include "map/CcarpgMcm.h"
#include "MNode.h"

class MapGrid
{
public:
	//MapGrid(ArpgMapData *mapdata);
	//Reset(ArpgMapData *mapdata);
	MapGrid();
	void setNodes(MNode** allnodes,unsigned short  row,unsigned short  col);
	void initNodeLink(MNode *node);
	MNode*  getNode(int x,int y);


	~MapGrid(void);

private:
	MNode **nodes;
	unsigned short  nodeLen;
	unsigned short  row;
	unsigned short  col;
	//void updateNodes(ArpgMapData *mapdata);


    //static double STRAIGHT_COST;
};

#endif
