#include "PlFileLoader.h"
#include "tolua++.h"
#include "tolua_fix.h"
#include "CCLuaEngine.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8) && (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <dirent.h>
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "CCFileUtilsAndroid.h"
#include "platform/CCCommon.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "android/asset_manager.h"
#include "android/asset_manager_jni.h"
#endif

#include "unzip.h"

#define LOW_SPEED_LIMIT 1L
#define LOW_SPEED_TIME 5L
#define BUFFER_SIZE    8192
#define MAX_FILENAME   512
#define MAX_BUFF_LEN   2048

/// help function 
static int loaderDefaultWriteFunc(void* ptr, size_t size, size_t nmeb, void* userdata)
{
	//CCLOG("loaderDefaultWriteFunc\n");
	return (size * nmeb);
}

static int loaderProgressFunc(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	static int percent = 0;
	PlFileLoader* pl = (PlFileLoader*)ptr;
	PlFileLoader::TaskInfo* curTask = pl->_curTask;

	int tmp = 0;
	if(curTask && curTask->opType == PlFileLoader::TYPE_DOWNlOAD)
	{
		tmp = (int)((curTask->startPos + nowDownloaded) / (curTask->startPos + totalToDownload) * 100);
	}else {
		int tmp = (int)(nowDownloaded / totalToDownload * 100);
	}

	if (percent != tmp && tmp >= 0)
	{
		percent = tmp;
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
			((PlFileLoader*)ptr)->onProgress(percent);
		});		
	}
	
	if(pl->_isPause){
		curl_easy_pause(pl->_curl, CURLPAUSE_RECV);
	}else{
		curl_easy_pause(pl->_curl, CURLPAUSE_CONT);
	}
	return 0;
}

static int loaderWriteFunc(void* ptr, size_t size, size_t nmeb, void* userdata)
{
	//CCLOG("loaderWriteFunc\n");
	FILE *fp = (FILE*)userdata;
	size_t written = fwrite(ptr, size, nmeb, fp);
	return (size * nmeb);
}

static int loaderWriteRamFunc(void* ptr, size_t size, size_t nmeb, void* userdata)
{
	//std::string *version = (std::string*)userdata;
	//version->append((char*)ptr, size * nmeb);
	PlFileLoader* loader = (PlFileLoader*)userdata;
	size_t leftCapacity = loader->_maxLen - loader->_curLen;
	size_t num = size * nmeb;

	size_t newLen = loader->_maxLen;
	if(leftCapacity < num){
		
		while(true){
			newLen = newLen * 1.5;
			if(newLen >= loader->_curLen + num)
				break;
		}
		
		char* newBuf = (char*)realloc(loader->_contentBuf, newLen);
		if(! newBuf){

			///重新分配内存错误，直接返回
			return 0;
		}
			
		loader->_contentBuf = newBuf;
		loader->_maxLen = newLen;

	}

	memmove(loader->_contentBuf + loader->_curLen, (char*)ptr, size * nmeb);
	loader->_curLen = loader->_curLen + size * nmeb;
		
	return (size * nmeb);
}

/// file utils
bool PlFileLoader::createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	mode_t processMask = umask(0);
	int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
	umask(processMask);
	if (ret != 0 && (errno != EEXIST))
	{
		return false;
	}

	return true;
#else
	BOOL ret = CreateDirectoryA(path, nullptr);
	if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
	{
		return false;
	}
	return true;
#endif
}

void PlFileLoader::deleteDirectory(const char* path)
{
	std::string _path(path);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	std::string command = "rm -r ";
	// Path may include space.
	command += "\"" + _path + "\"";
	system(command.c_str());
#else
	std::string command = "rd /s /q ";
	// Path may include space.
	command += "\"" + _path + "\"";
	system(command.c_str());
#endif
}

bool PlFileLoader::isDirectoryExist(const char* path)
{	
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *dir = nullptr;

	dir = opendir (path);
	if (!dir)
	{
		return false;
	}
	closedir(dir);
#else    
	if (GetFileAttributesA(path) == INVALID_FILE_ATTRIBUTES)
	{
		return false;
	}
#endif
	return true;
}

bool PlFileLoader::isFileExist(const char* path)
{
	FILE* handler = fopen(path, "rb");
	if(handler){
		fclose(handler);
		return true;
	}
	return false;
}

bool PlFileLoader::isZipFile(const char* path)
{
	unzFile zipfile = unzOpen(path);
	if (! zipfile)
	{
		return false;
	}
	unzClose(zipfile);
	return true;
}

bool PlFileLoader::unCompress(const char* storgePath, const char* path)
{
	// Open the zip file
	std::string _storagePath(storgePath);

	unzFile zipfile = unzOpen(path);
	if (! zipfile)
	{
		CCLOG("can not open downloaded zip file %s", path);
		return false;
	}

	// Get info about the zip file
	unz_global_info global_info;
	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLOG("can not read file global info of %s", path);
		unzClose(zipfile);
		return false;
	}

	// Buffer to hold data read from the zip file
	char readBuffer[BUFFER_SIZE];

	CCLOG("start uncompressing");

	// Loop to extract all files.
	uLong i;
	for (i = 0; i < global_info.number_entry; ++i)
	{
		// Get info about current file.
		unz_file_info fileInfo;
		char fileName[MAX_FILENAME];
		if (unzGetCurrentFileInfo(zipfile,
			&fileInfo,
			fileName,
			MAX_FILENAME,
			nullptr,
			0,
			nullptr,
			0) != UNZ_OK)
		{
			CCLOG("can not read file info");
			unzClose(zipfile);
			return false;
		}

		const std::string fullPath = _storagePath + fileName;

		// Check if this entry is a directory or a file.
		const size_t filenameLength = strlen(fileName);
		if (fileName[filenameLength-1] == '/')
		{
			// Entry is a direcotry, so create it.
			// If the directory exists, it will failed scilently.
			if (!createDirectory(fullPath.c_str()))
			{
				CCLOG("can not create directory %s", fullPath.c_str());
				unzClose(zipfile);
				return false;
			}
		}
		else
		{
			//There are not directory entry in some case.
			//So we need to test whether the file directory exists when uncompressing file entry
			//, if does not exist then create directory
			const std::string fileNameStr(fileName);

			size_t startIndex=0;

			size_t index=fileNameStr.find("/",startIndex);

			while(index != std::string::npos)
			{
				const std::string dir=_storagePath+fileNameStr.substr(0,index);

				FILE *out = fopen(dir.c_str(), "r");

				if(!out)
				{
					if (!createDirectory(dir.c_str()))
					{
						//CCLOG("can not create directory %s", dir.c_str());
						unzClose(zipfile);
						return false;
					}
					else
					{
						//CCLOG("create directory %s",dir.c_str());
					}
				}
				else
				{
					fclose(out);
				}

				startIndex=index+1;

				index=fileNameStr.find("/",startIndex);

			}



			// Entry is a file, so extract it.

			// Open current file.
			if (unzOpenCurrentFile(zipfile) != UNZ_OK)
			{
				CCLOG("can not open file %s", fileName);
				unzClose(zipfile);
				return false;
			}

			// Create a file to store current file.
			FILE *out = fopen(fullPath.c_str(), "wb");
			if (! out)
			{
				CCLOG("can not open destination file %s", fullPath.c_str());
				unzCloseCurrentFile(zipfile);
				unzClose(zipfile);
				return false;
			}

			// Write current file content to destinate file.
			int error = UNZ_OK;
			do
			{
				error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
				if (error < 0)
				{
					CCLOG("can not read zip file %s, error code is %d", fileName, error);
					unzCloseCurrentFile(zipfile);
					unzClose(zipfile);
					return false;
				}

				if (error > 0)
				{
					fwrite(readBuffer, error, 1, out);
				}
			} while(error > 0);

			fclose(out);
		}

		unzCloseCurrentFile(zipfile);

		// Goto next entry listed in the zip file.
		if ((i+1) < global_info.number_entry)
		{
			if (unzGoToNextFile(zipfile) != UNZ_OK)
			{
				CCLOG("can not read next file");
				unzClose(zipfile);
				return false;
			}
		}
	}

	CCLOG("end uncompressing");
	unzClose(zipfile);

	return true;
}

///fullpath
long PlFileLoader::getFileLength(const char* path)
{
	std::string fullPath = path;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	if (fullPath[0] != '/')
	{
		std::string relativePath = std::string();

		size_t position = fullPath.find("assets/");
		if (0 == position) {
			// "assets/" is at the beginning of the path and we don't want it
			relativePath += fullPath.substr(strlen("assets/"));
		} else {
			relativePath += fullPath;
		}

		if (nullptr == FileUtilsAndroid::assetmanager) {
			return 0;
		}

		// read asset data
		AAsset* asset =
			AAssetManager_open(FileUtilsAndroid::assetmanager,
			relativePath.c_str(),
			AASSET_MODE_UNKNOWN);
		if (nullptr == asset) {
			return 0;
		}

		off_t fileSize = AAsset_getLength(asset);

		AAsset_close(asset);
		return fileSize;
	}else
	{
		long fileSize = 0;
		do
		{
			// read rrom other path than user set it
			//CCLOG("GETTING FILE ABSOLUTE DATA: %s", filename);
			FILE *fp = fopen(fullPath.c_str(), "rb");
			CC_BREAK_IF(!fp);
			fseek(fp,0,SEEK_END);
			fileSize = ftell(fp);
			fseek(fp,0,SEEK_SET);
			fclose(fp);
		} while (0);

		return fileSize;
	}
#else
	long fileSize = 0;
	do
	{
		// read rrom other path than user set it
		//CCLOG("GETTING FILE ABSOLUTE DATA: %s", filename);
		FILE *fp = fopen(fullPath.c_str(), "rb");
		CC_BREAK_IF(!fp);
		fseek(fp,0,SEEK_END);
		fileSize = ftell(fp);
		fseek(fp,0,SEEK_SET);
		fclose(fp);
	} while (0);

	return fileSize;
	
#endif
}

/// class PlFileLoader
PlFileLoader* PlFileLoader::_fileLoader = nullptr;

PlFileLoader* PlFileLoader::getInstance()
{
	if(! _fileLoader){
		_fileLoader = new PlFileLoader();
		_fileLoader->init();
	}
	return _fileLoader;
}

PlFileLoader::PlFileLoader()
{
	_isDoing = false;
	_isNeedQuit = false;
	_loadingThread = nullptr;
	_curl = nullptr;
	_onLuaProgress = 0;
	_onLuaTaskReturn = 0;	
	_connectionTimeout = 20;
	_contentBuf = nullptr;
	_maxLen = MAX_BUFF_LEN;
	_curLen = 0;
	_isPause = false;
	_curTask = nullptr;
}

PlFileLoader::~PlFileLoader()
{
	CCLOG("PlFileLoader::~PlFileLoader()");
	if(_onLuaProgress)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaProgress);
	if(_onLuaTaskReturn)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaTaskReturn);

	curl_easy_cleanup(_curl);
	if(_contentBuf)
		free(_contentBuf);

	_fileLoader = nullptr;
}

bool PlFileLoader::init()
{
	_curl = curl_easy_init();
	if (! _curl){
		CCLOG("can not init curl");
		return false;
	}
	curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);
	if(_connectionTimeout)
		curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, _connectionTimeout);
	curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
	curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, LOW_SPEED_LIMIT);
	curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, LOW_SPEED_TIME);
	curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, true);
	curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, loaderProgressFunc);
	curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, this);

	_contentBuf = (char*)malloc(sizeof(char) * _maxLen);
	return true;
}

bool PlFileLoader::pause()
{
	_isPause = true;
	return true;
}

void PlFileLoader::resume()
{
	_isPause = false;
}

bool PlFileLoader::performTask(TaskInfo* task)
{
	if(_loadingThread == nullptr){
		_loadingThread = new std::thread(&PlFileLoader::loader, this);
		_loadingThread->detach();
	}

	if(_isDoing){
		CCLOG("one task is doning\n");
		return false;
	}

	_taskInfoQueueMutex.lock();
	_taskInfoQueue.push(task);
	_taskInfoQueueMutex.unlock();

	_isDoing = true;
	wakeUp();
	return true;
}

void PlFileLoader::setLuaCallback(int onLuaProgress, int onLuaTaskReturn)
{
	if(_onLuaProgress)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaProgress);
	if(_onLuaTaskReturn)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaTaskReturn);

	_onLuaProgress = onLuaProgress;
	_onLuaTaskReturn = onLuaTaskReturn;
}

void PlFileLoader::setTimeout(unsigned int timeout)
{
	if(_curl){
		curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, timeout);
		_connectionTimeout = timeout;
	}
}

void PlFileLoader::notifyQuit()
{
	_isNeedQuit = true;
	wakeUp();
}

void PlFileLoader::loader()
{
	CCLOG("thread start...\n");
	this->retain();
	TaskInfo* task = nullptr;

	while (true)
	{
		if(_isNeedQuit)
			break;
		///// do_task
		_taskInfoQueueMutex.lock();
		if(! _taskInfoQueue.empty()){
			task = _taskInfoQueue.front();
			_taskInfoQueue.pop();
			_taskInfoQueueMutex.unlock();
			_curTask = task;
			doTask(task);
		}else{
			_taskInfoQueueMutex.unlock();
		}
		if(_isNeedQuit)
			break;

		_curTask = nullptr;
		waitforCondition();		
	}

	this->release();
}

void PlFileLoader::doTask(TaskInfo* task)
{
	OP_TYPE opType = task->opType;
	if(opType == PlFileLoader::TYPE_UNCOMPRESS){

		std::string fileName = task->fileName;
		std::string storgePath = task->storgePath;
		bool ret = unCompress(storgePath.c_str(), fileName.c_str());
		OP_CODE opCode;
		if(ret){
			opCode = PlFileLoader::CODE_SUCCESS;
		}else{
			opCode = PlFileLoader::CODE_UNCOMPRESS;
		}
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([opCode, this]{
			this->onTaskReturn(PlFileLoader::TYPE_UNCOMPRESS, opCode, 0);
		});	
	}else if(opType == PlFileLoader::TYPE_GETLENGTH){

		curl_easy_setopt(_curl, CURLOPT_HEADER, 1);
		curl_easy_setopt(_curl, CURLOPT_NOBODY, 1);
		curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, loaderDefaultWriteFunc);
		curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, true);
		curl_easy_setopt(_curl, CURLOPT_RESUME_FROM, 0);
		curl_easy_setopt(_curl, CURLOPT_URL, task->url.c_str());
		CURLcode res = curl_easy_perform(_curl);

		OP_CODE opCode = PlFileLoader::CODE_SUCCESS;
		double length = 0;
		if(res == CURLE_OK){
			long retcode = 0;
			res =  curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE , &retcode); 
			if(res == CURLE_OK && retcode == 200){
				curl_easy_getinfo(_curl, CURLINFO_CONTENT_LENGTH_DOWNLOAD , &length); 
			}else{
				opCode = PlFileLoader::CODE_NOFILE;
			}
		}else{
			opCode = PlFileLoader::CODE_NETWORK;
		}

		Director::getInstance()->getScheduler()->performFunctionInCocosThread([opCode, length, this]{
			this->onTaskReturn(PlFileLoader::TYPE_GETLENGTH, opCode, length);
		});	
	}else if(opType == PlFileLoader::TYPE_GETCONTENT){
		_curLen = 0;
		OP_CODE code = PlFileLoader::CODE_SUCCESS;
		if (! _contentBuf){
			code = PlFileLoader::CODE_NO_MEMORY;
		}else{
			curl_easy_setopt(_curl, CURLOPT_HEADER, 0);
			curl_easy_setopt(_curl, CURLOPT_NOBODY, 0);
			curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, true);
			curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, loaderWriteRamFunc);
			curl_easy_setopt(_curl, CURLOPT_WRITEDATA, this);
			curl_easy_setopt(_curl, CURLOPT_RESUME_FROM, 0);
			curl_easy_setopt(_curl, CURLOPT_URL, task->url.c_str());
			CURLcode res = curl_easy_perform(_curl);

			if(res != CURLE_OK){
				code = PlFileLoader::CODE_NETWORK;
			}
		}
		
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([code, this]{
			this->onTaskReturn(PlFileLoader::TYPE_GETCONTENT, code);
		});		

	}else if(opType == PlFileLoader::TYPE_DOWNlOAD){

		setCurlArgs(task);

		std::string fileName = task->fileName;
		//bool isExist = PlFileLoader::isFileExist(fileName.c_str());
		FILE* fp = nullptr;
		long startPos = task->startPos;
		if(startPos <= 0){
			curl_easy_setopt(_curl, CURLOPT_RESUME_FROM, 0);
			fp = fopen(fileName.c_str(), "wb");
		}else if(startPos > 0){
			curl_easy_setopt(_curl, CURLOPT_RESUME_FROM, startPos);
			fp = fopen(fileName.c_str(), "a+b");
		}		

		if(!fp){
			Director::getInstance()->getScheduler()->performFunctionInCocosThread([this]{
				this->onTaskReturn(PlFileLoader::TYPE_DOWNlOAD, PlFileLoader::CODE_CREATE_FILE);
			});

		}else{
			curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
			CURLcode res = curl_easy_perform(_curl);
			OP_CODE code = PlFileLoader::CODE_SUCCESS;
			if(res != CURLE_OK){
				code = PlFileLoader::CODE_NETWORK;
			}
			fclose(fp);
			Director::getInstance()->getScheduler()->performFunctionInCocosThread([code, this]{
				this->onTaskReturn(PlFileLoader::TYPE_DOWNlOAD, code);
			});			
		}		

	}

	delete task;
}

void PlFileLoader::setCurlArgs(TaskInfo* task)
{
	curl_easy_setopt(_curl, CURLOPT_HEADER, 0);
	curl_easy_setopt(_curl, CURLOPT_NOBODY, 0);
	curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
	curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, loaderWriteFunc);
	curl_easy_setopt(_curl, CURLOPT_URL, task->url.c_str());
}

void PlFileLoader::wakeUp()
{
	_sleepCondition.notify_one();
}

void PlFileLoader::waitforCondition()
{
	std::unique_lock<std::mutex> lk(_sleepMutex);
	_sleepCondition.wait(lk);
}



/// callbacks
void PlFileLoader::onProgress(int percent)
{
	//CCLOG("percent:%d%%", percent);
	if(_onLuaProgress){
		auto defaultEngine = LuaEngine::getInstance();
		if(defaultEngine){
			LuaStack* stack = defaultEngine->getLuaStack();
			stack->pushObject(this, "cc.PlFileLoader");
			stack->pushInt(percent);
			stack->executeFunctionByHandler(_onLuaProgress, 2);
		}
	}
}


void PlFileLoader::onTaskReturn(OP_TYPE opType, OP_CODE opCode, double length)
{
	_isDoing = false;
	//CCLOG("PlFileLoader::onTaskReturn : optype:%d, opcode:%d, length:%f", opType, opCode, length);
	/*if(opType == PlFileLoader::TYPE_DOWNlOAD && opCode == PlFileLoader::CODE_SUCCESS){
		TaskInfo* info = new TaskInfo();
		info->opType = TYPE_UNCOMPRESS;
		std::string path = FileUtils::getInstance()->getWritablePath();
		info->storgePath = path + "/tmp/";
		info->fileName = path + "/test.zip";
		performTask(info);
	}*/

	if(_onLuaTaskReturn){
		auto defaultEngine = LuaEngine::getInstance();
		if(defaultEngine){
			LuaStack* stack = defaultEngine->getLuaStack();
			stack->pushObject(this, "cc.PlFileLoader");
			stack->pushInt(opType);
			stack->pushInt(opCode);
			stack->pushFloat(length);

			if(opType == PlFileLoader::TYPE_GETCONTENT && opCode == PlFileLoader::CODE_SUCCESS){
				lua_pushlstring(stack->getLuaState(), _contentBuf, _curLen);
			}else{
				lua_pushstring(stack->getLuaState(), "");
			}
			stack->executeFunctionByHandler(_onLuaTaskReturn, 5);
		}
	}
}
