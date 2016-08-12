#ifndef __LUA_COCOS2DX_CUSTOM_MANUAL
#define __LUA_COCOS2DX_CUSTOM_MANUAL

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif
#include "tolua_fix.h"
#include "CCLuaEngine.h"
#include "net/Plsocket.h"
#include "map/CCGameMap.h"
#include "map/CCMapAstar.h"
#include "net/PlFileLoader.h"
#include "net/PlFileUploader.h"
#include "lsqlite/lsqlite3.h" //sqlite3数据库

#include "renren-ext.h"
#include "cocos2d.h"

USING_NS_CC_EXT;
USING_NS_CC;

class dpRevLuaHandler : public IRichEventHandler {
public:
	dpRevLuaHandler(int hclick=0, int hmoved=0)
		: IRichEventHandler(hclick, hmoved)
	{

	}

	virtual void onClick(IRichNode* root, IRichElement* ele, int _id, const Vec2&pt)
	{
		if ( m_clickhandle )
		{
			REleHTMLTouchable* touchable = dynamic_cast<REleHTMLTouchable*>(ele);
			auto defaultEngine = LuaEngine::getInstance();
			if ( defaultEngine && touchable )
			{
				LuaStack* stack = defaultEngine->getLuaStack();
				stack->pushInt(_id);
				stack->pushString(touchable->getName().c_str(), touchable->getName().size());
				stack->pushString(touchable->getValue().c_str(), touchable->getValue().size());
				stack->pushFloat(pt.x);
				stack->pushFloat(pt.y);
				stack->executeFunctionByHandler(m_clickhandle, 5);
			}
		}
	}

	virtual void onMoved(IRichNode* root, IRichElement* ele, int _id, const Vec2& location, const Vec2& delta)
	{
		if ( m_movedhandle )
		{
			REleHTMLTouchable* touchable = dynamic_cast<REleHTMLTouchable*>(ele);
			auto defaultEngine = LuaEngine::getInstance();
			if ( defaultEngine && touchable )
			{
				LuaStack* stack = defaultEngine->getLuaStack();
				stack->pushInt(_id);
				stack->pushString(touchable->getName().c_str(), touchable->getName().size());
				stack->pushString(touchable->getValue().c_str(), touchable->getValue().size());
				stack->pushFloat(location.x);
				stack->pushFloat(location.y);
				stack->pushFloat(delta.x);
				stack->pushFloat(delta.y);
				stack->executeFunctionByHandler(m_movedhandle, 7);
			}
		}
	}

};


////解析cocos2dx的node
class REleCCBNode : public REleBase{
public:
	virtual bool isCachedComposit() { return true; }
	virtual bool canLinewrap() { return true; }
	virtual bool needBaselineCorrect() { return true;  }

	REleCCBNode();
	virtual ~REleCCBNode();

protected:
	virtual bool onParseAttributes(class IRichParser* parser, attrs_t* attrs );
	virtual bool onCompositFinish(class IRichCompositor* compositor);
	virtual void onRenderPost(RRichCanvas canvas);

public:
	Node* m_ccbNode;
	bool m_dirty;
};

TOLUA_API int CustomLuaCocos2d(lua_State* tolua_S);
#endif // !__LUA_COCOS2DX_CUSTOM_MANUAL
