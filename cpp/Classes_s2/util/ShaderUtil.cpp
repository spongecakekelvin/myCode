#include "ShaderUtil.h"

NS_CC_BEGIN

ShaderUtil::~ShaderUtil()
{
}

void ShaderUtil::setGray(CCSprite * spr, bool bGray)
{
	if(spr)
	{
		if(bGray)
		{
			GLProgram * glProgram = new GLProgram();
			glProgram->initWithFilenames("res/shaders/ccShader_Gray.vsh", "res/shaders/ccShader_Gray.fsh");
			glProgram->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
			glProgram->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            glProgram->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

			glProgram->link();
			glProgram->updateUniforms();

			spr->setShaderProgram(glProgram);

			// spr->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureGray));
		}
		else
		{
			spr->setShaderProgram(GLProgramCache::getInstance()->getGLProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP)); 
			//spr->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor)); 
		}
	}
}


NS_CC_END