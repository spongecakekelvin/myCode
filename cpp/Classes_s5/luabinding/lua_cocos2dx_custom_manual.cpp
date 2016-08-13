
#include "lua_cocos2dx_custom_manual.h"
#include "LuaBasicConversions.h"
#include "dfont/dfont_utility.h"

static double localGetTimer()
{
	struct timeval tv;     
	gettimeofday(&tv,NULL);     
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

static REleBase *createFun(const char* name)
{
	if(0 == strcmp(name, "cs"))
		return new REleCCBNode;
	return new REleHTMLNotSupport;
}

///解析cocos2dx node
bool REleCCBNode::onCompositFinish(class IRichCompositor* compositor) 
{
	return true;
}

void REleCCBNode::onRenderPost(RRichCanvas canvas)
{
	if ( m_dirty )
	{
		RPos pos = getGlobalPosition();
		m_ccbNode->setPosition(Vec2(pos.x, pos.y - m_rMetrics.rect.size.h));
		canvas.root->addCCNode(m_ccbNode);
		m_dirty = false;
	}

	REleBase::onRenderPost(canvas);
}

REleCCBNode::REleCCBNode()
	: m_ccbNode(NULL), m_dirty(false)
{

}

REleCCBNode::~REleCCBNode()
{
	CC_SAFE_RELEASE(m_ccbNode);
}

static std::string expressionPath = "";

static std::string getexpressionPath()
{
	if(expressionPath.empty()){
		lua_State *lstate = LuaEngine::getInstance()->getLuaStack()->getLuaState();
		lua_getfield(lstate, LUA_GLOBALSINDEX, "getexpressionPath");
		if(lua_isfunction(lstate, -1)){
			int ret = lua_pcall(lstate, 0, 1, 0);
			if(ret == 0){
				//no error
				const char* pexpressionPath = tolua_tostring(lstate, -1, NULL);
				if(pexpressionPath)
					expressionPath = pexpressionPath;
			}	
			lua_pop(lstate, 1);
		}
	}
	return expressionPath;
}

bool REleCCBNode::onParseAttributes(class IRichParser* parser, attrs_t* attrs )
{
	std::string path = getexpressionPath();
	if(path.empty())
		return false;

	///加载表情资源
	std::string name=(*attrs)["id"];
	if(name.empty())
		return false;

	///从lua配置中读取基本信息
	lua_State *lstate = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	lua_getfield(lstate, LUA_GLOBALSINDEX, "getexpressionConfig");
	if(! lua_isfunction(lstate, -1)){
		lua_pop(lstate, 1);	
		return false;
	}

	lua_pushstring(lstate, name.c_str());
	int ret = lua_pcall(lstate, 1, 4, 0);
	if(ret== 0){
		float scale = tolua_tonumber(lstate, -1, 0);
		const char* format = tolua_tostring(lstate, -2, NULL);
		float time = tolua_tonumber(lstate, -3, 0);
		int num = tolua_tonumber(lstate, -4, 0);

		lua_pop(lstate, 4);
		if(format && time && num){
			SpriteFrameCache* frameCache = SpriteFrameCache::getInstance();
			frameCache->addSpriteFramesWithFile(path.c_str());	//, "expression.pvr.ccz");
			SpriteFrame* frame = NULL;
			Vector<SpriteFrame*> frameList;
			for(int k=1;k<=num;k++){
				frame = frameCache->getSpriteFrameByName(CCString::createWithFormat(format, k)->getCString());
				if(!frame)
					return false;
				frameList.pushBack(frame);
			}

			Animation* animation = Animation::createWithSpriteFrames(frameList);
			animation->setLoops(-1);  
			animation->setDelayPerUnit(time/num); 
			Animate* animate = Animate::create(animation);
			m_ccbNode = Sprite::createWithSpriteFrameName(CCString::createWithFormat(format, 1)->getCString());
			if(m_ccbNode){
				m_ccbNode ->runAction(animate);
				m_ccbNode->setScale(scale, scale);

				m_ccbNode->retain();
				m_ccbNode->setAnchorPoint(Vec2(0.0f, 0.0f));
				m_ccbNode->ignoreAnchorPointForPosition(true);
				m_rMetrics.rect.size.w = (short)m_ccbNode->getContentSize().width * scale;
				m_rMetrics.rect.size.h = (short)m_ccbNode->getContentSize().height * scale;
				m_rMetrics.advance.x = m_rMetrics.rect.size.w;
				m_rMetrics.rect.pos.y = m_rMetrics.rect.size.h;
				m_dirty = true;

				return true;
			}

			return false;
		}
		return false;
	}else{
		lua_pop(lstate, 1);
		return false;
	}
}

///////////////////////////////////////////////////////////////
/* method: create of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_create00
static int tolua_Cocos2d_CCHTMLLabel_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		//CCHTMLLabel* htmllabel = NULL;
		size_t len = 0;
		const char *pstr = lua_tolstring(tolua_S, 2, &len);

		bool ok = true;
		cocos2d::Size psize;
		ok &= luaval_to_size(tolua_S, 3, &psize);
		if(!ok){
			psize = cocos2d::Size(0,0);
		}
		LUA_FUNCTION clickfuncID = (  toluafix_ref_function(tolua_S,4,0));
		LUA_FUNCTION movedfuncID = (  toluafix_ref_function(tolua_S,5,0));

		const char* fontAlias = lua_tostring(tolua_S, 6);
		if(!fontAlias){
			fontAlias = "default";
		}
		CCHTMLLabel* tolua_ret = CCHTMLLabel::createWithString(pstr, psize, fontAlias, createFun);
	
		if(clickfuncID || movedfuncID)
			tolua_ret->registerLuaListener((void*)tolua_ret, new dpRevLuaHandler(clickfuncID, movedfuncID));
		object_to_luaval<cocos2d::extension::CCHTMLLabel>(tolua_S, "cc.CCHTMLLabel",(cocos2d::extension::CCHTMLLabel*)tolua_ret);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_create'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* method: setString of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setString
static int tolua_Cocos2d_CCHTMLLabel_setString(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		const char *pstr = tolua_tostring(tolua_S, 2, NULL);
		if(plabel && pstr)
		{
			plabel->setString(pstr);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setString'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* method: getString of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_getString
static int tolua_Cocos2d_CCHTMLLabel_getString(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		if(plabel)
		{
			const std::string str = plabel->getString();
			tolua_pushstring(tolua_S, str.c_str());
			return 1;
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_getString'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* method: appendString of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_appendString
static int tolua_Cocos2d_CCHTMLLabel_appendString(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		const char *pstr = tolua_tostring(tolua_S, 2, NULL);
		if(plabel)
		{
			plabel->appendString(pstr);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_appendString'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setPreferredSize of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setPreferredSize
static int tolua_Cocos2d_CCHTMLLabel_setPreferredSize(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnumber(tolua_S, 3, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		int width = tolua_tonumber(tolua_S, 2, 0);
		int height = tolua_tonumber(tolua_S, 3, 0);
		RSize rsize(width, height);
		if(plabel)
			plabel->setPreferredSize(rsize);
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setPreferredSize'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setDefaultColor of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setDefaultColor
static int tolua_Cocos2d_CCHTMLLabel_setDefaultColor(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		int colorvalue = tolua_tonumber(tolua_S, 2, 0);
		if(plabel)
		{
			plabel->setDefaultColor(colorvalue);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setDefaultColor'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setDefaultSpacing of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setDefaultSpacing
static int tolua_Cocos2d_CCHTMLLabel_setDefaultSpacing(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		int space = tolua_tonumber(tolua_S, 2, 0);
		if(plabel)
		{
			plabel->setDefaultSpacing(space);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setDefaultSpacing'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setDefaultPadding of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setDefaultPadding
static int tolua_Cocos2d_CCHTMLLabel_setDefaultPadding(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		int padding = tolua_tonumber(tolua_S, 2, 0);
		if(plabel)
		{
			plabel->setDefaultPadding(padding);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setDefaultPadding'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setDefaultWrapline of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setDefaultWrapline
static int tolua_Cocos2d_CCHTMLLabel_setDefaultWrapline(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isboolean(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		int color = tolua_toboolean(tolua_S, 2, 0);
		if(plabel)
		{
			plabel->setDefaultWrapline(color);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setDefaultWrapline'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setDefaultAlignment of class  CCHTMLLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHTMLLabel_setDefaultAlignment
static int tolua_Cocos2d_CCHTMLLabel_setDefaultAlignment(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.CCHTMLLabel",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCHTMLLabel *plabel = (CCHTMLLabel*)tolua_tousertype(tolua_S, 1, NULL);
		EAlignment alignment = (EAlignment)((int)tolua_tonumber(tolua_S, 2, 0));
		if(plabel)
		{
			plabel->setDefaultAlignment(alignment);
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'CCHTMLLabel_setDefaultAlignment'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/////plsocket
#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_create
int tolua_Cocos2d_Plsocket_create(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.Plsocket",0,&tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		unsigned int inbufsize;
		unsigned int outbufsize;
		if(!luaval_to_uint32(tolua_S, 2, &inbufsize)){
			inbufsize = 16*1024;
		}
		if(!luaval_to_uint32(tolua_S, 3, &outbufsize)){
			outbufsize = 8*1024;
		}

		Plsocket* pl = Plsocket::create(inbufsize, outbufsize);
		if(pl){
			object_to_luaval<Plsocket>(tolua_S, "cc.Plsocket", pl);
			return 1;
		}
		return 0;		
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_create'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncConnect
int tolua_Cocos2d_Plsocket_asyncConnect(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl){
			std::string ip;
			unsigned int port;
			int timeout;
			luaval_to_std_string(tolua_S, 2, &ip);
			luaval_to_uint32(tolua_S,3,&port);
			LUA_FUNCTION connHandlerID = (  toluafix_ref_function(tolua_S,4,0));
			LUA_FUNCTION errHandlerID = (  toluafix_ref_function(tolua_S,5,0));
			CCLOG("connHandlerID;%d, errHandlerID:%d\n", connHandlerID, errHandlerID);
			if(!luaval_to_int32(tolua_S, 6, &timeout))
				timeout = 20;
			
			bool ok = pl->asyncConnect(ip.c_str(), port, connHandlerID, errHandlerID,timeout);
			lua_pushboolean(tolua_S, ok ? 1:0);
			return 1;

		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncConnect'.",&tolua_err);
	return 0;
#endif
}
#endif

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncSend
int tolua_Cocos2d_Plsocket_asyncSend(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0;
		}

		const char* pdata = nullptr;
		size_t len = 0;
		pdata = lua_tolstring(tolua_S, 2, &len);
		if(pdata){
			bool ok = pl->asyncSend(pdata, len);
			if(ok)
				lua_pushboolean(tolua_S, 1);
			else 
				lua_pushboolean(tolua_S, 0);
			return 1;
		}		
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncSend'.",&tolua_err);
	return 0;
#endif
}
#endif

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncRecv
int tolua_Cocos2d_Plsocket_asyncRecv(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0 ;
		}
		pl->luaAsyncRecv([tolua_S](Plsocket* data){
			lua_pushlstring(tolua_S, data->_inbuf, data->_inbuflen);
		});
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncRecv'.",&tolua_err);
	return 0;
#endif
}
#endif

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncClose
int tolua_Cocos2d_Plsocket_asyncClose(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0 ;
		}
		pl->asyncClose();
		lua_pushboolean(tolua_S, 1);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncClose'.",&tolua_err);
	return 0;
#endif
}
#endif

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncClearBuf
int tolua_Cocos2d_Plsocket_asyncClearBuf(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0 ;
		}
		pl->socket_clear();
		lua_pushboolean(tolua_S, 1);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncClearBuf'.",&tolua_err);
	return 0;
#endif
}
#endif

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_socket_state
int tolua_Cocos2d_Plsocket_socket_state(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0 ;
		}
		int state = pl->socket_state();
		lua_pushnumber(tolua_S, state);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_socket_state'.",&tolua_err);
	return 0;
#endif
}
#endif

#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncGet
int tolua_Cocos2d_Plsocket_asyncGet(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0 ;
		}
		int wantlen = 0;
		int startpos = 0;
		luaval_to_int32(tolua_S, 2, &startpos);
		luaval_to_int32(tolua_S, 3, &wantlen);
		
		int inbuflen = pl->_inbuflen;
		if(wantlen == 0){
			lua_pushboolean(tolua_S, 1);
			lua_pushstring(tolua_S, "");
			return 2;
		}

		if(inbuflen >= wantlen+startpos){
			lua_pushboolean(tolua_S, 1);
			lua_pushlstring(tolua_S, pl->_inbuf+startpos, wantlen);
			return 2;
		}else{
			lua_pushboolean(tolua_S, 0);
			return 1;
		}
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncGet'.",&tolua_err);
	return 0;
#endif
}
#endif


#ifndef TOLUA_DISABLE_tolua_Cocos2d_Plsocket_asyncClearBufNum
int tolua_Cocos2d_Plsocket_asyncClearBufNum(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S,1,"cc.Plsocket",0,&tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		Plsocket *pl = (Plsocket*)tolua_tousertype(tolua_S, 1, NULL);
		if(pl == nullptr){
			return 0 ;
		}
		
		int num = 0;
		luaval_to_int32(tolua_S, 2, &num);
		pl->clearInbufNum(num);
		lua_pushboolean(tolua_S, 1);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Plsocket_asyncClearBufNum'.",&tolua_err);
	return 0;
#endif
}
#endif


////extend fileutils
#ifndef TOLUA_DISABLE_tolua_cocos2dx_FileUtils_getFileData
int tolua_cocos2dx_FileUtils_getFileData(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.FileUtils",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string filename;
		bool ok = luaval_to_std_string(tolua_S, 2, &filename);
		if(!ok){
			return 0;
		}
		ssize_t size = 0;
		unsigned char* buf = FileUtils::getInstance()->getFileData(filename, "rb+", &size);
		if(buf){
			lua_pushlstring(tolua_S, (char*)buf, size);
			delete [] buf;
			return 1;
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'FileUtils_getFileData'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

////extend Sprite
#ifndef TOLUA_DISABLE_tolua_cocos2dx_Sprite_opacityClicked
int tolua_cocos2dx_Sprite_opacityClicked(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.Sprite",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isnumber(tolua_S, 3, 0, &tolua_err)
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		long tt = localGetTimer();
		Sprite* ret =  (Sprite*)tolua_tousertype(tolua_S, 1, NULL);
		if(ret){
			int8_t data[4] = {0};
			float x = lua_tonumber(tolua_S, 2);
			float y = lua_tonumber(tolua_S, 3);
			
			RenderTexture* renderTexture = RenderTexture::create(1,1, Texture2D::PixelFormat::RGBA8888);
			renderTexture->beginWithClear(0,0,0,0);
			Vec2 oldpt = ret->getPosition();
			Vec2 anchorPt = ret->getAnchorPoint();
			ret->setAnchorPoint(Vec2(0,0));
			ret->setPosition(Vec2(-x, -y));
			ret->visit();
			ret->setPosition(oldpt);
			ret->setAnchorPoint(anchorPt);
			//glReadPixels(0,0, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, data);
			renderTexture->end();
			auto renderer = Director::getInstance()->getRenderer();
			renderer->render();
			Image* pImage = renderTexture->newImage();

			bool isOpacity = [=]()->bool{
				Color4B c(0, 0, 0, 0);
				unsigned char* data = pImage->getData();
				unsigned int* pixel = (unsigned int*)data;
				c.r = *pixel & 0xff;
				c.g = (*pixel >> 8) & 0xff;
				c.b = (*pixel >> 16) & 0xff;
				c.a = (*pixel >> 24) & 0xff; 
				return (c.r>0 || c.g>0 || c.b>0) && c.a>0;
			}();			
			pImage->release();
			lua_pushboolean(tolua_S, isOpacity ? 1 : 0);
			return 1;
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'Sprite_opacityClicked'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/////////// PlFileLoader
#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_createDirectory
int tolua_Cocos2d_PlFileLoader_createDirectory(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = lua_tostring(tolua_S, 2);
		bool ret = PlFileLoader::createDirectory(path.c_str());
		lua_pushboolean(tolua_S, ret ? 1 : 0);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_createDirectory'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_isDirectoryExist
int tolua_Cocos2d_PlFileLoader_isDirectoryExist(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = lua_tostring(tolua_S, 2);
		bool ret = PlFileLoader::isDirectoryExist(path.c_str());
		lua_pushboolean(tolua_S, ret ? 1 : 0);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_isDirectoryExist'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_deleteDirectory
int tolua_Cocos2d_PlFileLoader_deleteDirectory(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = lua_tostring(tolua_S, 2);
		if(PlFileLoader::isDirectoryExist(path.c_str())){
			PlFileLoader::deleteDirectory(path.c_str());
		}
		
		lua_pushboolean(tolua_S, 1);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_deleteDirectory'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_deleteFile
int tolua_Cocos2d_PlFileLoader_deleteFile(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = lua_tostring(tolua_S, 2);
		if(remove(path.c_str()) != 0 ){
			lua_pushboolean(tolua_S, 0);
		}else{
			lua_pushboolean(tolua_S, 1);
		}
		
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_deleteFile'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_isFileExist
int tolua_Cocos2d_PlFileLoader_isFileExist(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = lua_tostring(tolua_S, 2);
		bool ret = PlFileLoader::isFileExist(path.c_str());
		lua_pushboolean(tolua_S, ret ? 1:0);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_isFileExist'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_isZipFile
int tolua_Cocos2d_PlFileLoader_isZipFile(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = lua_tostring(tolua_S, 2);
		bool ret = PlFileLoader::isZipFile(path.c_str());
		lua_pushboolean(tolua_S, ret ? 1:0);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_isZipFile'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_unCompress
int tolua_Cocos2d_PlFileLoader_unCompress(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 3, 0, &tolua_err)
		//!toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err) ||
		//!tolua_isnoobj(tolua_S,5,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string storgPath = lua_tostring(tolua_S, 2);
		std::string fileName = lua_tostring(tolua_S, 3);

		bool ret = PlFileLoader::unCompress(storgPath.c_str(), fileName.c_str());
		lua_pushboolean(tolua_S, ret ? 1:0);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_unCompress'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_getFileLength
int tolua_Cocos2d_PlFileLoader_getFileLength(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string fileName = lua_tostring(tolua_S, 2);
		fileName = FileUtils::getInstance()->fullPathForFilename(fileName.c_str());
		long length = PlFileLoader::getFileLength(fileName.c_str());
		lua_pushnumber(tolua_S, length);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_getFileLength'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_getInstance
int tolua_Cocos2d_PlFileLoader_getInstance(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileLoader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = PlFileLoader::getInstance();
		if(ret){
			object_to_luaval<PlFileLoader>(tolua_S, "cc.PlFileLoader", ret);
			return 1;
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_getInstance'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_performTask
int tolua_Cocos2d_PlFileLoader_performTask(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 4, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 5, 0, &tolua_err) ||
		!tolua_isboolean(tolua_S, 6, 0, &tolua_err) ||
		!tolua_isnumber(tolua_S, 7, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		PlFileLoader::TaskInfo* info = new PlFileLoader::TaskInfo();
		if(ret && info){
			info->opType = (PlFileLoader::OP_TYPE)(int)lua_tonumber(tolua_S, 2); 
			info->fileName = lua_tostring(tolua_S, 3);
			info->storgePath = lua_tostring(tolua_S, 4);
			info->url = lua_tostring(tolua_S, 5);
			info->needProgress = lua_toboolean(tolua_S, 6);
			info->startPos = (long)lua_tonumber(tolua_S, 7);
			
			bool ok = ret->performTask(info);
			if(!ok){
				delete info;
			}
			lua_pushboolean(tolua_S, ok ? 1:0);

		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_performTask'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_setCallback
int tolua_Cocos2d_PlFileLoader_setCallback(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);

		LUA_FUNCTION onLuaProgressID = (  toluafix_ref_function(tolua_S,2,0));
		LUA_FUNCTION onTaskReturnID = (  toluafix_ref_function(tolua_S,3,0));

		ret->setLuaCallback(onLuaProgressID, onTaskReturnID);
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_setCallback'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_setTimeout
int tolua_Cocos2d_PlFileLoader_setTimeout(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isnumber(tolua_S, 2, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		unsigned int timeout = (unsigned int)lua_tonumber(tolua_S, 2);
		ret->setTimeout(timeout);
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_setTimeout'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_pause
int tolua_Cocos2d_PlFileLoader_pause(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		bool res = ret->pause();
		lua_pushboolean(tolua_S, res ? 1:0);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_pause'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_resume
int tolua_Cocos2d_PlFileLoader_resume(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		ret->resume();
		lua_pushboolean(tolua_S, 1);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_resume'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_notifyQuit
int tolua_Cocos2d_PlFileLoader_notifyQuit(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		ret->notifyQuit();
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_notifyQuit'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_performGetLength
int tolua_Cocos2d_PlFileLoader_performGetLength(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		PlFileLoader::TaskInfo* info = new PlFileLoader::TaskInfo();
		if(ret && info){
			info->opType = PlFileLoader::TYPE_GETLENGTH;
			info->fileName = "";
			info->storgePath = "";
			info->url = lua_tostring(tolua_S, 2);
			info->needProgress = false;
			info->startPos = 0;

			bool ok = ret->performTask(info);
			if(!ok){
				delete info;
			}
			lua_pushboolean(tolua_S, ok ? 1:0);
			lua_pushstring(tolua_S, ok ? "succ":"failed");
			return 2;
		}
		lua_pushboolean(tolua_S, 0);
		lua_pushstring(tolua_S, "memerr");
		return 2;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_performGetLength'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_perfomrGetContent
int tolua_Cocos2d_PlFileLoader_perfomrGetContent(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		PlFileLoader::TaskInfo* info = new PlFileLoader::TaskInfo();
		if(ret && info){
			info->opType = PlFileLoader::TYPE_GETCONTENT;
			info->fileName = "";
			info->storgePath = "";
			info->url = lua_tostring(tolua_S, 2);
			info->needProgress = false;
			info->startPos = 0;

			bool ok = ret->performTask(info);
			if(!ok){
				delete info;
			}
			lua_pushboolean(tolua_S, ok ? 1:0);
			lua_pushstring(tolua_S, ok ? "succ":"failed");
			return 2;
		}
		lua_pushboolean(tolua_S, 0);
		lua_pushstring(tolua_S, "memerr");
		return 2;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_perfomrGetContent'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE



#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_performUncpmpress
int tolua_Cocos2d_PlFileLoader_performUncpmpress(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 3, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		PlFileLoader::TaskInfo* info = new PlFileLoader::TaskInfo();
		if(ret && info){
			info->opType = PlFileLoader::TYPE_UNCOMPRESS;
			info->fileName = lua_tostring(tolua_S, 2);
			info->storgePath = lua_tostring(tolua_S, 3);
			info->url = "";
			info->needProgress = false;
			info->startPos = 0;

			bool ok = ret->performTask(info);
			if(!ok){
				delete info;
			}
			lua_pushboolean(tolua_S, ok ? 1:0);
			lua_pushstring(tolua_S, ok ? "succ":"failed");
			return 2;
		}
		lua_pushboolean(tolua_S, 0);
		lua_pushstring(tolua_S, "memerr");
		return 2;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_performUncpmpress'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileLoader_performDownLoad
int tolua_Cocos2d_PlFileLoader_performDownLoad(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileLoader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
		!tolua_isboolean(tolua_S, 4, 0, &tolua_err) ||
		!tolua_isnumber(tolua_S, 5, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileLoader* ret = (PlFileLoader*)tolua_tousertype(tolua_S, 1, nullptr);
		PlFileLoader::TaskInfo* info = new PlFileLoader::TaskInfo();
		if(ret && info){
			info->opType = PlFileLoader::TYPE_DOWNlOAD;
			info->fileName = lua_tostring(tolua_S, 2);
			info->storgePath = "";
			info->url = lua_tostring(tolua_S, 3);
			info->needProgress = lua_toboolean(tolua_S, 4);
			info->startPos = (long)lua_tonumber(tolua_S, 5);

			bool ok = ret->performTask(info);
			if(!ok){
				delete info;
			}
			lua_pushboolean(tolua_S, ok ? 1:0);
			lua_pushstring(tolua_S, ok ? "succ":"failed");
			return 2;
		}
		lua_pushboolean(tolua_S, 0);
		lua_pushstring(tolua_S, "memerr");
		return 2;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileLoader_performDownLoad'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

/////////PlFileUploader

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileUploader_getInstance
int tolua_Cocos2d_PlFileUploader_getInstance(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"cc.PlFileUploader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileUploader* ret = PlFileUploader::getInstance();
		if(ret){
			object_to_luaval<PlFileUploader>(tolua_S, "cc.PlFileUploader", ret);
			return 1;
		}
		return 0;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileUploader_getInstance'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileUploader_performUpload
int tolua_Cocos2d_PlFileUploader_performUpload(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileUploader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 3, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileUploader* ret = (PlFileUploader*)tolua_tousertype(tolua_S, 1, nullptr);
		const char* serverpath = lua_tostring(tolua_S, 2);
		const char* filename = lua_tostring(tolua_S, 3);
		if (ret){
			ret->upload(serverpath, filename);
		}
		lua_pushboolean(tolua_S, 1);
		return 1;
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileUploader_performUpload'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileUploader_performGetFile
int tolua_Cocos2d_PlFileUploader_performGetFile(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileUploader",0,&tolua_err) ||
		!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
		!tolua_isstring(tolua_S, 3, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileUploader* ret = (PlFileUploader*)tolua_tousertype(tolua_S, 1, nullptr);
		const char* url = lua_tostring(tolua_S, 2);
		const char* saveName = lua_tostring(tolua_S, 3);
		if (ret){
			bool ok = ret->getFile(url, saveName);
			lua_pushboolean(tolua_S, ok ? 1:0);
			return 1;
		}		
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileUploader_getFile'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileUploader_setCallback
int tolua_Cocos2d_PlFileUploader_setCallback(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileUploader",0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileUploader* ret = (PlFileUploader*)tolua_tousertype(tolua_S, 1, nullptr);

		LUA_FUNCTION onput = (  toluafix_ref_function(tolua_S,2,0));
		LUA_FUNCTION onget = (  toluafix_ref_function(tolua_S,3,0));

		if (ret){
			ret->setCallback(onput, onget);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}		
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileUploader_setCallback'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_PlFileUploader_setPutTimeout
int tolua_Cocos2d_PlFileUploader_setPutTimeout(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"cc.PlFileUploader",0,&tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		PlFileUploader* ret = (PlFileUploader*)tolua_tousertype(tolua_S, 1, nullptr);

		int timeout = lua_tonumber(tolua_S, 2);

		if (ret){
			ret->setPutTimeout(timeout);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}		
	}

#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'PlFileUploader_setPutTimeout'.",&tolua_err);
	return 0;
#endif

}
#endif //#ifndef TOLUA_DISABLE

//////////////
int lua_register_cocos2dx_CCHTMLLabel(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"cc.CCHTMLLabel");
	tolua_cclass(tolua_S,"CCHTMLLabel","cc.CCHTMLLabel","cc.Node",nullptr);

	tolua_beginmodule(tolua_S,"CCHTMLLabel");
		tolua_constant(tolua_S, "e_align_left", e_align_left);
		tolua_constant(tolua_S, "e_align_right", e_align_right);
		tolua_constant(tolua_S, "e_align_right", e_align_center);
		tolua_constant(tolua_S, "e_align_right", e_align_bottom);
		tolua_constant(tolua_S, "e_align_right", e_align_top);
		tolua_constant(tolua_S, "e_align_right", e_align_middle);

		tolua_function(tolua_S,"create",tolua_Cocos2d_CCHTMLLabel_create00);
		tolua_function(tolua_S, "setString",tolua_Cocos2d_CCHTMLLabel_setString);
		tolua_function(tolua_S, "getString",tolua_Cocos2d_CCHTMLLabel_getString);
		tolua_function(tolua_S, "appendString",tolua_Cocos2d_CCHTMLLabel_appendString);
		tolua_function(tolua_S, "setPreferredSize",tolua_Cocos2d_CCHTMLLabel_setPreferredSize);
		tolua_function(tolua_S, "setDefaultColor",tolua_Cocos2d_CCHTMLLabel_setDefaultColor);
		tolua_function(tolua_S, "setDefaultSpacing",tolua_Cocos2d_CCHTMLLabel_setDefaultSpacing);
		tolua_function(tolua_S, "setDefaultPadding",tolua_Cocos2d_CCHTMLLabel_setDefaultPadding);
		tolua_function(tolua_S, "setDefaultAlignment",tolua_Cocos2d_CCHTMLLabel_setDefaultAlignment);
		tolua_function(tolua_S, "setDefaultWrapline",tolua_Cocos2d_CCHTMLLabel_setDefaultWrapline);
	tolua_endmodule(tolua_S);
	std::string typeName = typeid(cocos2d::extension::CCHTMLLabel).name();
	g_luaType[typeName] = "cc.CCHTMLLabel";
	g_typeCast["CCHTMLLabel"] = "cc.CCHTMLLabel";
	return 1;
}

int lua_register_cocos2dx_Plsocket(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"cc.Plsocket");
	tolua_cclass(tolua_S,"Plsocket","cc.Plsocket","cc.Ref",nullptr);
	tolua_beginmodule(tolua_S,"Plsocket");
		tolua_constant(tolua_S, "IO_SUCC", Plsocket::IO_SUCC);
		tolua_constant(tolua_S, "IO_FAILED", Plsocket::IO_FAILED);
		tolua_constant(tolua_S, "IO_CLOSED", Plsocket::IO_CLOSED);
		tolua_constant(tolua_S, "IO_TIMEOUT", Plsocket::IO_TIMEOUT);
		tolua_constant(tolua_S, "SOCKET_UNCONNECT", Plsocket::SOCKET_UNCONNECT);
		tolua_constant(tolua_S, "SOCKET_CONNECTING", Plsocket::SOCKET_CONNECTING);
		tolua_constant(tolua_S, "SOCKET_CONNECTED", Plsocket::SOCKET_CONNECTED);
		tolua_constant(tolua_S, "SOCKET_CLOSED", Plsocket::SOCKET_CLOSED);

		tolua_function(tolua_S,"create",tolua_Cocos2d_Plsocket_create);
		tolua_function(tolua_S,"asyncConnect",tolua_Cocos2d_Plsocket_asyncConnect);
		tolua_function(tolua_S,"asyncSend",tolua_Cocos2d_Plsocket_asyncSend);
		tolua_function(tolua_S,"asyncRecv",tolua_Cocos2d_Plsocket_asyncRecv);
		tolua_function(tolua_S,"asyncClose",tolua_Cocos2d_Plsocket_asyncClose);
		tolua_function(tolua_S,"asyncClearBuf",tolua_Cocos2d_Plsocket_asyncClearBuf);
		tolua_function(tolua_S,"socketState",tolua_Cocos2d_Plsocket_socket_state);
		tolua_function(tolua_S,"asyncGet",tolua_Cocos2d_Plsocket_asyncGet);
		tolua_function(tolua_S,"asyncClearBufNum",tolua_Cocos2d_Plsocket_asyncClearBufNum);

	tolua_endmodule(tolua_S);
	std::string typeName = typeid(Plsocket).name();
	g_luaType[typeName] = "cc.Plsocket";
	g_typeCast["Plsocket"] = "cc.Plsocket";
	return 1;
}


int lua_register_cocos2dx_PlFileLoader(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"cc.PlFileLoader");
	tolua_cclass(tolua_S, "PlFileLoader", "cc.PlFileLoader", "cc.Ref", nullptr);
	tolua_beginmodule(tolua_S,"PlFileLoader");
		tolua_constant(tolua_S, "CODE_SUCCESS", PlFileLoader::CODE_SUCCESS);
		tolua_constant(tolua_S, "CODE_CREATE_FILE", PlFileLoader::CODE_CREATE_FILE);
		tolua_constant(tolua_S, "CODE_NETWORK", PlFileLoader::CODE_NETWORK);
		tolua_constant(tolua_S, "CODE_UNCOMPRESS", PlFileLoader::CODE_UNCOMPRESS);
		tolua_constant(tolua_S, "TYPE_GETLENGTH", PlFileLoader::TYPE_GETLENGTH);
		tolua_constant(tolua_S, "TYPE_DOWNlOAD", PlFileLoader::TYPE_DOWNlOAD);
		tolua_constant(tolua_S, "TYPE_UNCOMPRESS", PlFileLoader::TYPE_UNCOMPRESS);
		tolua_constant(tolua_S, "TYPE_GETCONTENT", PlFileLoader::TYPE_GETCONTENT);

		tolua_function(tolua_S,"createDirectory",tolua_Cocos2d_PlFileLoader_createDirectory);
		tolua_function(tolua_S, "isDirectoryExist", tolua_Cocos2d_PlFileLoader_isDirectoryExist);
		tolua_function(tolua_S, "deleteDirectory", tolua_Cocos2d_PlFileLoader_deleteDirectory);
		tolua_function(tolua_S, "deleteFile", tolua_Cocos2d_PlFileLoader_deleteFile);
		////isFileExist 主要用于判断下载的文件，对于assets下的文件无效
		tolua_function(tolua_S, "isFileExist", tolua_Cocos2d_PlFileLoader_isFileExist);
		tolua_function(tolua_S, "isZipFile", tolua_Cocos2d_PlFileLoader_isZipFile);
		tolua_function(tolua_S, "unCompress", tolua_Cocos2d_PlFileLoader_unCompress);
		tolua_function(tolua_S, "getFileLength", tolua_Cocos2d_PlFileLoader_getFileLength);

		tolua_function(tolua_S, "getInstance", tolua_Cocos2d_PlFileLoader_getInstance);
		tolua_function(tolua_S, "performTask", tolua_Cocos2d_PlFileLoader_performTask);
		tolua_function(tolua_S, "setCallback", tolua_Cocos2d_PlFileLoader_setCallback);
		tolua_function(tolua_S, "setTimeout", tolua_Cocos2d_PlFileLoader_setTimeout);
		tolua_function(tolua_S, "pause", tolua_Cocos2d_PlFileLoader_pause);
		tolua_function(tolua_S, "resume", tolua_Cocos2d_PlFileLoader_resume);
		tolua_function(tolua_S, "notifyQuit", tolua_Cocos2d_PlFileLoader_notifyQuit);
		tolua_function(tolua_S, "performGetLength", tolua_Cocos2d_PlFileLoader_performGetLength);
		tolua_function(tolua_S, "performUncompress", tolua_Cocos2d_PlFileLoader_performUncpmpress);
		tolua_function(tolua_S, "performDownLoad", tolua_Cocos2d_PlFileLoader_performDownLoad);
		tolua_function(tolua_S, "performGetContent", tolua_Cocos2d_PlFileLoader_perfomrGetContent);
		
	tolua_endmodule(tolua_S);
	std::string typeName = typeid(PlFileLoader).name();
	g_luaType[typeName] = "cc.PlFileLoader";
	g_typeCast["PlFileLoader"] = "cc.PlFileLoader";
	return 1;
}

int lua_register_cocos2dx_PlFileUploader(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"cc.PlFileUploader");
	tolua_cclass(tolua_S, "PlFileUploader", "cc.PlFileUploader", "cc.Ref", nullptr);
	tolua_beginmodule(tolua_S,"PlFileUploader");
		tolua_function(tolua_S, "getInstance", tolua_Cocos2d_PlFileUploader_getInstance);
		tolua_function(tolua_S, "performUpload", tolua_Cocos2d_PlFileUploader_performUpload);
		tolua_function(tolua_S, "performGetFile", tolua_Cocos2d_PlFileUploader_performGetFile);
		tolua_function(tolua_S, "setCallback", tolua_Cocos2d_PlFileUploader_setCallback);
		tolua_function(tolua_S, "setPutTimeout", tolua_Cocos2d_PlFileUploader_setPutTimeout);
	tolua_endmodule(tolua_S);
	std::string typeName = typeid(PlFileUploader).name();
	g_luaType[typeName] = "cc.PlFileUploader";
	g_typeCast["PlFileUploader"] = "cc.PlFileUploader";
	return 1;
}

////extend 
static void extendFileUtils(lua_State* tolua_S)
{
	lua_pushstring(tolua_S, "cc.FileUtils");
	lua_rawget(tolua_S, LUA_REGISTRYINDEX);
	if (lua_istable(tolua_S,-1))
	{
		lua_pushstring(tolua_S,"getFileData");
		lua_pushcfunction(tolua_S,tolua_cocos2dx_FileUtils_getFileData );
		lua_rawset(tolua_S,-3);
	}
	lua_pop(tolua_S, 1);
}

static void extendSprite(lua_State* tolua_S)
{
	lua_pushstring(tolua_S, "cc.Sprite");
	lua_rawget(tolua_S, LUA_REGISTRYINDEX);
	if (lua_istable(tolua_S,-1))
	{
		lua_pushstring(tolua_S,"opacityClicked");
		lua_pushcfunction(tolua_S,tolua_cocos2dx_Sprite_opacityClicked);
		lua_rawset(tolua_S,-3);
	}
	lua_pop(tolua_S, 1);
}



///get system timer
static int msNow(lua_State* tolua_S)
{
	double ms = localGetTimer();
	//lua_Number ret = ms / 1000.0;
	lua_pushnumber(tolua_S, ms/1000);
	//CCLOG("============%f\n", ms);
	return 1;
}

static unsigned char* fontData = nullptr;
static ssize_t size = 0;
static bool initDefaultFont()
{
	using namespace dfont;
	if(!fontData)
	{
		std::string filepath = "number/MicrosoftYaHei.ttf";
		std::string resdirname = "res/";
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		filepath = "../../"+resdirname + filepath;
		std::string pathToSave = FileUtils::getInstance()->getWritablePath();
		pathToSave += "s3b6lhuxo/number/MicrosoftYaHei.ttf";
		fontData = FileUtils::getInstance()->getFileData(pathToSave, "rb", &size);

		if (fontData==nullptr)
		{
			fontData = FileUtils::getInstance()->getFileData(filepath, "rb", &size);
		}

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
		filepath = resdirname+ filepath;
		fontData = FileUtils::getInstance()->getFileData(filepath, "rb", &size);
#else
		filepath = resdirname+filepath;

		std::string pathToSave = FileUtils::getInstance()->getWritablePath();
		pathToSave += "s3b6lhuxo/number/MicrosoftYaHei.ttf";
		fontData = FileUtils::getInstance()->getFileData(pathToSave, "rb", &size);

		if (fontData==nullptr)
		{
			fontData = FileUtils::getInstance()->getFileData(filepath, "rb", &size);
		}

#endif
		
	}
	//default font
	FontCatalog* font_catalog = NULL;
	font_catalog = FontFactory::instance()->create_font_from_data(
		"default1", fontData, size, 0xffffff00, 20, e_plain, 0.0f, 0xffffffff, 0);
	if(font_catalog)
		return true;
	return false;
}

static int createHtmlFont(lua_State* ls){
	std::string fontsize = "20";
	if(lua_isstring(ls, 1))
		fontsize = lua_tostring(ls, 1);

	std::string fontAlias = "font" + fontsize;

	using namespace dfont;
	//default font
	FontCatalog* font_catalog = NULL;
	font_catalog = FontFactory::instance()->create_font_from_data(
		fontAlias.c_str(), fontData, size, 0xffffffff, atoi(fontsize.c_str()), e_plain, 0.0f, 0xffffffff, 0);
	if(font_catalog){
		lua_pushstring(ls, fontAlias.c_str());		
		return 1;
	}
	return 0;
}

static int gencrypt(lua_State* tolua_S)
{
	ZipUtils::setPvrEncryptionKeyPart(0, 0xffff2222);
	ZipUtils::setPvrEncryptionKeyPart(1, 0xc156267d);
	ZipUtils::setPvrEncryptionKeyPart(2, 0x838fbafc);
	ZipUtils::setPvrEncryptionKeyPart(3, 0x3301d248);
	return 0;
}
///custom luabinding
TOLUA_API int CustomLuaCocos2d(lua_State* tolua_S)
{
	initDefaultFont();

	extendFileUtils(tolua_S);
	extendSprite(tolua_S);
	lua_register(tolua_S, "localGetTimer", msNow);
	lua_register(tolua_S, "gcreateFont", createHtmlFont);
	lua_register(tolua_S, "gencrypt", gencrypt);
	tolua_open(tolua_S);
	tolua_module(tolua_S,"cc",0);
	tolua_beginmodule(tolua_S,"cc");
		lua_register_cocos2dx_CCHTMLLabel(tolua_S);
		lua_register_cocos2dx_Plsocket(tolua_S);
		lua_register_cocos2dx_PlFileLoader(tolua_S);
		lua_register_cocos2dx_PlFileUploader(tolua_S);
	tolua_endmodule(tolua_S);

	
	return 1;
}