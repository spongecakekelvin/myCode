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
#ifndef __CC_CCARPG_MCM_H__
#define __CC_CCARPG_MCM_H__

#include "cocos2d.h"

typedef struct arpgMapElementData
{
	
	unsigned char itemType;
	unsigned short tx;
	unsigned short ty;
	int display;
	int id;
	

}ArpgMapElementData;


typedef struct arpgMapTransferData
{
	
	unsigned short tx;
	unsigned short ty;
	
	unsigned short tar_tx;
	unsigned short tar_ty;

	unsigned short minLevel;
	unsigned short maxLevel;
	int id;
	int tar_Map;
	int display;

}ArpgMapTransferData;

typedef struct _arpgMapData
{
	int map_id;
	unsigned char  isSub;
	unsigned short  tileRow;
	unsigned short tileCol;
	//int  offsetX;
	//int  offsetY;
	unsigned short   width;
	unsigned short   height;
	//int stx;
	//int  sty;
	unsigned short  ssw;
	unsigned short  ssh;
	
	unsigned short eleLen;
	unsigned short traLen;

	unsigned short clientSliceW ;
	unsigned short clientSliceH ;
	unsigned short cellW ;
	unsigned short cellH ;
	float ssscale;
	std::string  url;
	//std::string  fileName;
	std::string name;

	ArpgMapElementData* elements;
	ArpgMapTransferData* transfers;
	std::vector<ArpgMapElementData*> **sliceEle;



	unsigned char **tiles;

}ArpgMapData;



//class CC_DLL MessageDispatcher : public cocos2d::Ref
class  CcarpgMcm : public cocos2d::Ref
{
public:
	static CcarpgMcm* getInstance();
	//CcarpgMcm();
	~CcarpgMcm(void);

public:
	void setCurrentMapData(int mapid,int clientSliceX,int clientSliceY,int cellW,int cellH);
	unsigned char getNodeValue(int x,int y);
	bool isSomeArea(int x,int y,int value);
	std::vector<ArpgMapElementData*>* getElementsInfo(int x,int y);
	ArpgMapTransferData* getPropertyTrans(int tx,int ty);
	ArpgMapData currentMapData;

	int xClientSliceNum;
	int yClientSliceNum;

private:
	
	char* encodeString( char *p,int *len);
	void encodeArpgMapTransferData(ArpgMapTransferData* result, char *content,int *len);
	void encodeArpgMapElementData(ArpgMapElementData* result, char *content,int *len);

	void freeCurrentMapData();

};

#endif 