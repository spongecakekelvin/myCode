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
#ifndef _C_CCARPG_MAP_NODE_H_
#define _C_CCARPG_MAP_NODE_H_

#include <vector>

class MLink;


class MNode
{
public:
	int  x;
	int  y;
	double  f;
	double  g;
	double  h;
	bool  walkable;
	MNode*  parent;
	int  version;
	std::vector<MLink*> links;
	bool  initLink;

	MNode(int xvalue,int yvalue);
	MNode();
	~MNode(void);
};

#endif
