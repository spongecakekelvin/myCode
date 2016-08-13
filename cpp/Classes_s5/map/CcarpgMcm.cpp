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
#include "cocos2d.h"
#include "base/CCScriptSupport.h"
#include "audio/include/SimpleAudioEngine.h"
#include "CCLuaEngine.h"
#include "CcarpgMcm.h"
#include "astar/MNode.h"
#include "astar/MCAstar.h"
#include "MessageDispatcher.h"
#include "zlib.h"

USING_NS_CC;

extern long getTimer();  

//CcarpgMcm::CcarpgMcm()
//{
//	currentMapData.tiles = NULL;
//	currentMapData.elements = NULL;
//	currentMapData.transfers = NULL;
//}

CcarpgMcm::~CcarpgMcm()
{
	this->freeCurrentMapData();
}

CcarpgMcm* CcarpgMcm::getInstance()
{
	static CcarpgMcm* instance = NULL;
	if(instance == NULL) 
	{
		instance = new CcarpgMcm();
		instance->currentMapData.tiles = NULL;
		instance->currentMapData.elements = NULL;
		instance->currentMapData.transfers = NULL;
		instance->currentMapData.sliceEle = NULL;
	}

	return instance;
}

void CcarpgMcm::setCurrentMapData(int mapid,int clientSliceX,int clientSliceY,int cellW,int cellH)
{
	int recordtt = getTimer();
	auto filename = String::createWithFormat("map/mcm/%d.mcm", mapid);
	std::string filepath = FileUtils::getInstance()->fullPathForFilename(filename->getCString());
	//FILE *fp = fopen(filepath.c_str(), "rb+");  
	unsigned char cellvalue;

	ssize_t size;
	unsigned char *content =FileUtils::getInstance()->getFileData(filename->getCString(), "rb", &size); 

	//if(fp)
    if(content)
	{
		this->freeCurrentMapData();
		//fseek(fp,0,2);
		//int size =ftell(fp);
		//fseek(fp,0,0);
		//unsigned char *content = new unsigned char[size];
		//fread( content, size, 1, fp );
		//fclose( fp );

		uLongf uncomLen = 64 * 1024;
		unsigned char *finalData = new unsigned char[uncomLen];
		memset(finalData, 0, uncomLen);
		uncompress(finalData,&uncomLen,content,size);
		//int finallen = ZipUtils::inflateMemory(content, size, &finalData);
		//CCLOG("origin=%d,final=%d",size,finallen);
		CCLOG("origin=%d,final=%d",size,uncomLen);

		currentMapData.clientSliceW = clientSliceX;
		currentMapData.clientSliceH = clientSliceY;
		currentMapData.cellW = cellW;
		currentMapData.cellH = cellH;

		char *p = (char *)finalData;
		int rlen;
		//short stringlentemp;
		char *pstr;
		currentMapData.map_id =  *(int *)(p);
		p+=4;

		currentMapData.isSub =  *(unsigned char *)(p);
		p+=1;

		currentMapData.tileRow =  *(unsigned short *)(p);
		p+=2;

		currentMapData.tileCol =  *(unsigned short *)(p);
		p+=2;

		//currentMapData.offsetX =  *(int *)(p);
		//p+=4;

		//currentMapData.offsetY =  *(int *)(p);
		//p+=4;

		currentMapData.width =  *(unsigned short *)(p);
		p+=2;

		currentMapData.height =  *(unsigned short *)(p);
		p+=2;

		//currentMapData.stx =  *(int *)(p);
		//p+=4;

		//currentMapData.sty =  *(int *)(p);
		//p+=4;

		currentMapData.ssw =  *(unsigned short *)(p);
		p+=2;

		currentMapData.ssh =  *(unsigned short *)(p);
		p+=2;

		currentMapData.ssscale = *(float *)(p);
		p+=4;

		currentMapData.eleLen = *(unsigned short *)(p);
		p+=2;

		currentMapData.traLen = *(unsigned short *)(p);
		p+=2;

		pstr = this->encodeString(p,&rlen);
		if(pstr)
		{
			currentMapData.url = pstr;
			delete pstr;
			//CCLOG(currentMapData.url.c_str());
		}
		else
		{
			currentMapData.url = "";
		}
		p+=rlen;

		//pstr = this->encodeString(p,&rlen);
		//if(pstr)
		//{
		//	currentMapData.fileName = pstr;
		//}
		//else
		//{
		//	currentMapData.fileName = "";
		//}
		//p+=rlen;

		pstr = this->encodeString(p,&rlen);
		if(pstr)
		{
			currentMapData.name = pstr;
			delete pstr;
		}
		else
		{
			currentMapData.name = "";
		}
		p+=rlen;

		/*
		stringlentemp = *(short *)(p);
		p+=2;
		if(stringlentemp>0)
		{
		pstr = new char(stringlentemp+1);
		memcpy(pstr,p,stringlentemp);
		pstr[stringlentemp]=0;
		currentMapData.url = pstr;
		}
		else
		{
		currentMapData.url = "";
		}
		p+=stringlentemp;

		stringlentemp = *(short *)(p);
		p+=2;
		if(stringlentemp>0)
		{
		pstr = new char(stringlentemp+1);
		memcpy(pstr,p,stringlentemp);
		pstr[stringlentemp]=0;
		currentMapData.fileName = pstr;
		}
		else
		{
		currentMapData.fileName = "";
		}
		p+=stringlentemp;

		stringlentemp = *(short *)(p);
		p+=2;
		if(stringlentemp>0)
		{
		pstr = new char(stringlentemp+1);
		memcpy(pstr,p,stringlentemp);
		pstr[stringlentemp]=0;
		currentMapData.name = pstr;
		}
		else
		{
		currentMapData.name = "";
		}
		p+=stringlentemp;
		*/

		this->xClientSliceNum = ceil(currentMapData.width*1.0 / clientSliceX);
		this->yClientSliceNum = ceil(currentMapData.height*1.0 / clientSliceY);
		//CCLOG("a %d,%d",this->xClientSliceNum,this->yClientSliceNum);
		//CCLOG("b %d,%d",currentMapData.width,currentMapData.height);
		//CCLOG("b %d,%d",clientSliceX,clientSliceY);

		currentMapData.sliceEle = new std::vector<ArpgMapElementData*>* [this->xClientSliceNum];
		for(int i=0; i<this->xClientSliceNum; i++)  
		{
			currentMapData.sliceEle[i] = new std::vector<ArpgMapElementData*> [this->yClientSliceNum];
			//for(int j=0; j<this->yClientSliceNum; j++)  
			//{
			//	currentMapData.sliceEle[i][j] = NULL;
			//}
		}

		int srow;
		int scol;
		if(currentMapData.eleLen>0)
		{
			currentMapData.elements = new ArpgMapElementData[currentMapData.eleLen];
			for(int i=0;i<currentMapData.eleLen;i++)
			{
				this->encodeArpgMapElementData(&currentMapData.elements[i],p,&rlen);
				p+=rlen;
				srow = floor((currentMapData.elements[i].tx*cellW*1.0)/clientSliceX);
				scol = floor((currentMapData.elements[i].ty*cellH*1.0)/clientSliceY);
				//CCLOG("%d,%d,%d,%d",srow,scol,currentMapData.elements[i].tx,currentMapData.elements[i].ty);
				currentMapData.sliceEle[srow][scol].push_back(&currentMapData.elements[i]);
			}
		}


		if(currentMapData.traLen>0)
		{
			currentMapData.transfers = new ArpgMapTransferData[currentMapData.traLen];
			for(int i=0;i<currentMapData.traLen;i++)
			{
				this->encodeArpgMapTransferData(&currentMapData.transfers[i],p,&rlen);
				p+=rlen;
			}
		}

		currentMapData.tiles = new unsigned char* [currentMapData.tileRow];
		MNode** nodes = new MNode* [currentMapData.tileRow*currentMapData.tileCol];
		for(int i=0; i<currentMapData.tileRow; i++)  
		{
			currentMapData.tiles[i] = new unsigned char [currentMapData.tileCol];
			for(int j=0; j<currentMapData.tileCol; j++)  
			{
				cellvalue = *(unsigned char *)(p);
				currentMapData.tiles[i][j] = cellvalue;

				if((cellvalue&0x01) == 0x01)
				{
					nodes[i*currentMapData.tileCol+j] = new MNode(i,j);
					//CCLOG("%d,%d",i,j);
				}
				else
				{
					nodes[i*currentMapData.tileCol+j] = NULL;
				}
				p+=1;
			}
		}
		//CCLOG("%d,%d,%d",79,88,currentMapData.tiles[79/*][88]);
		//CCLOG("%d,%d,%d",83,93,currentMapData.tiles[83][93]);
		//CCLOG("%d,%d,%d",51,156,currentMapData.tiles[51][156]);
		//CCLOG("%d",nodes[51*currentMapData.tileRow+156]==N*/ULL);


		MCAstar::getInstance()->updateMap(nodes,currentMapData.tileRow,currentMapData.tileCol);

		CCLOG("解析成功");

		delete content;
		delete finalData;

		/*unsigned char test1 = *(unsigned char *)(p);
		p++;
		double test2 =      *(double *)(p);
		p+=8;
		int test3 =  *(int *)(p);
		p+=4;
		short test4 = *(short *)(p);
		p+=2;*/
	}
	CCLOG("mcm need time %d in c++",(getTimer()-recordtt));
}

char* CcarpgMcm::encodeString( char *p,int *len)
{
	short stringlentemp;
	char *pstr = NULL;

	stringlentemp = *(short *)(p);
	p+=2;
	if(stringlentemp>0)
	{
		//CCLOG("fuck errro %d",stringlentemp);
		pstr = new char[stringlentemp+1];
		memcpy(pstr,(char *)p,stringlentemp);
		pstr[stringlentemp]=0;
	}
	*len = (stringlentemp+2);
	return pstr;
}

void CcarpgMcm::encodeArpgMapTransferData(ArpgMapTransferData* result, char *content,int *len)
{
	char *p = content;
	result->id =  *(int *)(p);
	p+=4;

	result->display =  *(int *)(p);
	p+=4;

	result->tx =  *(unsigned short *)(p);
	p+=2;

	result->ty =  *(unsigned short *)(p);
	p+=2;

	result->tar_Map =  *(int *)(p);
	p+=4;

	result->tar_tx =  *(unsigned short *)(p);
	p+=2;

	result->tar_ty =  *(unsigned short *)(p);
	p+=2;

	result->minLevel =  *(unsigned short *)(p);
	p+=2;

	result->maxLevel =  *(unsigned short *)(p);
	p+=2;

	*len = (p-content);
}

void CcarpgMcm::encodeArpgMapElementData(ArpgMapElementData* result, char *content,int *len)
{
	char *p = content;
	result->id =  *(int *)(p);
	p+=4;

	result->display =  *(int *)(p);
	p+=4;

	result->tx =  *(unsigned short *)(p);
	p+=2;

	result->ty =  *(unsigned short *)(p);
	p+=2;

	result->itemType =  *(unsigned char *)(p);
	p+=1;

	//if(result->itemType==0)
	//{
	//	CCLog("id = %d %d %d,%d",result->id,result->display,result->tx,result->ty);
	//}
	*len = (p-content);
}


unsigned char CcarpgMcm::getNodeValue(int x,int y)
{
	if(x<currentMapData.tileRow && y<currentMapData.tileCol)
	{
		return currentMapData.tiles[x][y];
	}

	return 0;
}

bool CcarpgMcm::isSomeArea(int x,int y,int value)
{
	unsigned char result = getNodeValue(x,y);
	return ((result & value) == value);
}


ArpgMapTransferData* CcarpgMcm::getPropertyTrans(int tx,int ty)
{
	ArpgMapTransferData *p;
	for(int i=0;i<currentMapData.traLen;i++)
	{
		p = &currentMapData.transfers[i];
		if(((p->tx-1)<=tx && (p->tx+1)>=tx) && ((p->ty-1)<=ty && (p->ty+1)>=ty))
		{

		}
	}

	return NULL;
}

std::vector<ArpgMapElementData*>* CcarpgMcm::getElementsInfo(int x,int y)
{

	if(x<this->xClientSliceNum && y<this->yClientSliceNum)
	{
		return &currentMapData.sliceEle[x][y];
	}
	//else
	//{
	//	CCLOG("%d,%d",x,y);
	//}
	return NULL;
}

void CcarpgMcm::freeCurrentMapData()
{
	if(currentMapData.tiles)
	{
		for(int i=0; i<currentMapData.tileRow; i++)  
			delete[] currentMapData.tiles[i];  
		delete[] currentMapData.tiles; 
	}

	if(currentMapData.elements)
	{
		delete [] currentMapData.elements;
	}

	if(currentMapData.transfers)
	{
		delete [] currentMapData.transfers;
	}

	if(currentMapData.sliceEle)
	{
		for(int i=0; i<this->xClientSliceNum; i++)  
			delete[] currentMapData.sliceEle[i];  
		delete[] currentMapData.sliceEle; 
	}


	currentMapData.tiles = NULL;
	currentMapData.elements = NULL;
	currentMapData.transfers = NULL;
	currentMapData.sliceEle = NULL;

}