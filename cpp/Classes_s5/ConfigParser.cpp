
#include "json/document.h"
#include "json/filestream.h"
#include "json/stringbuffer.h"
#include "json/writer.h"
#include "ConfigParser.h"

// ConfigParser
ConfigParser *ConfigParser::s_sharedInstance = NULL;
ConfigParser *ConfigParser::getInstance(void)
{
    if (!s_sharedInstance)
    {
        s_sharedInstance = new ConfigParser();
    }
    return s_sharedInstance;
}

bool ConfigParser::isInit()
{
    return _isInit;
}

void ConfigParser::readConfig()
{
    _isInit = true;
    _consolePort = 6010;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	string filecfg = "gamecore/config/config.json";
#else 
	string filecfg = "src/gamecore/config/config.json";
#endif

    
    
    string fileContent;
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID && !defined(NDEBUG)) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS && defined(COCOS2D_DEBUG))
//    string fullPathFile = FileUtils::getInstance()->getWritablePath();
//    fullPathFile.append("debugruntime/");
//    fullPathFile.append(filecfg.c_str());
//    fileContent=FileUtils::getInstance()->getStringFromFile(fullPathFile.c_str());
//#endif

    if (fileContent.empty()) {
        filecfg=FileUtils::getInstance()->fullPathForFilename(filecfg.c_str());
        fileContent=FileUtils::getInstance()->getStringFromFile(filecfg.c_str());
    }

    if(!fileContent.empty())
    {
        _docRootjson.Parse<0>(fileContent.c_str());
        if (_docRootjson.HasMember("init_cfg"))
        {
            if(_docRootjson["init_cfg"].IsObject())
            {
                const rapidjson::Value& objectInitView = _docRootjson["init_cfg"];
                if (objectInitView.HasMember("width") && objectInitView.HasMember("height"))
                {
                    _initViewSize.width = objectInitView["width"].GetUint();
                    _initViewSize.height = objectInitView["height"].GetUint();
                    if (_initViewSize.height>_initViewSize.width)
                    {
                        float tmpvalue =_initViewSize.height;
                        _initViewSize.height = _initViewSize.width;
                         _initViewSize.width = tmpvalue;
                    }
                    
                }
                if (objectInitView.HasMember("name") && objectInitView["name"].IsString())
                {
                    _viewName = objectInitView["name"].GetString();
                }
				if (objectInitView.HasMember("terminalIp") && objectInitView["terminalIp"].IsString())
				{
					_terminalIp = objectInitView["terminalIp"].GetString();
				}
				if (objectInitView.HasMember("updateURL") && objectInitView["updateURL"].IsString())
				{
					_updateURL = objectInitView["updateURL"].GetString();
				}
				
				if (objectInitView.HasMember("gameplatform") && objectInitView["gameplatform"].IsString())
				{
					_gameplatform = objectInitView["gameplatform"].GetString();
				}
				if (objectInitView.HasMember("libver") && objectInitView["libver"].IsString())
				{
					_libver = objectInitView["libver"].GetString();
				}
                if (objectInitView.HasMember("isLandscape") && objectInitView["isLandscape"].IsBool()) {
                    _isLandscape = objectInitView["isLandscape"].GetBool();
                }
				if (objectInitView.HasMember("useCocosIde") && objectInitView["useCocosIde"].IsBool()) {
					_useCocosIde = objectInitView["useCocosIde"].GetBool();
				}
				
				if (objectInitView.HasMember("cpplog") && objectInitView["cpplog"].IsBool()) {
					_cpplog = objectInitView["cpplog"].GetBool();
				}

                if (objectInitView.HasMember("entry") && objectInitView["entry"].IsString()) {
                    _entryfile = objectInitView["entry"].GetString();
                }
                if (objectInitView.HasMember("consolePort")){
                    _consolePort = objectInitView["consolePort"].GetUint();
                }
            }
        }
        if (_docRootjson.HasMember("simulator_screen_size"))
        {
            const rapidjson::Value& ArrayScreenSize = _docRootjson["simulator_screen_size"];
            if (ArrayScreenSize.IsArray())
            {
                for (int i=0; i<ArrayScreenSize.Size(); i++)
                {
                    const rapidjson::Value& objectScreenSize = ArrayScreenSize[i];
                    if (objectScreenSize.HasMember("title") && objectScreenSize.HasMember("width") && objectScreenSize.HasMember("height"))
                    {
                        _screenSizeArray.push_back(SimulatorScreenSize(objectScreenSize["title"].GetString(), objectScreenSize["width"].GetUint(), objectScreenSize["height"].GetUint()));
                    }
                }
            }
        }
        
    }

}

ConfigParser::ConfigParser(void):_isInit(false),_isLandscape(true),_useCocosIde(false),_cpplog(false)
{
    _initViewSize.setSize(960,640);
    _viewName = "s3arpg";
	_terminalIp = "127.0.0.1";
	 _updateURL = "127.0.0.1";
	_gameplatform ="debug";
	_libver = "0";
    _entryfile = "src/main.lua";
}

rapidjson::Document& ConfigParser::getConfigJsonRoot()
{
    return _docRootjson;
}

string ConfigParser::getInitViewName()
{
    return _viewName;
}


string ConfigParser::getTerminalIp()
{
	return _terminalIp;
}

string ConfigParser::getUpdateURL()
{
	return _updateURL;
}

string ConfigParser::getGameplatform()
{
	return _gameplatform;
}
string ConfigParser::getLibVersion()
{
	return _libver;
}


string ConfigParser::getEntryFile()
{
    return _entryfile;
}

Size ConfigParser::getInitViewSize()
{
    return _initViewSize;
}

bool ConfigParser::isLanscape()
{
    return _isLandscape;
}

bool ConfigParser::useCocosIde()
{
	return _useCocosIde;
}

bool ConfigParser::cpplog()
{
	return _cpplog;
}


int ConfigParser::getConsolePort()
{
    return _consolePort;
}
int ConfigParser::getScreenSizeCount(void)
{
    return (int)_screenSizeArray.size();
}

const SimulatorScreenSize ConfigParser::getScreenSize(int index)
{
    return _screenSizeArray.at(index);
}
