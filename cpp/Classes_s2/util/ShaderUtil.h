#ifndef __SHADER_UTIL_H__
#define __SHADER_UTIL_H__

#include "cocos2d.h"

NS_CC_BEGIN

class ShaderUtil{ 

public: 
    ShaderUtil(); 
    ~ShaderUtil();

	static void setGray(Sprite * spr, bool bGray);
    //static void AddColorGray(CCSprite * spr); 
    //static void RemoveColorGray(CCSprite * spr); 
};

NS_CC_END

#endif