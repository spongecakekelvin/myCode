#include "PlFileUploader.h"

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

static size_t post_read_callback(void *ptr, size_t size, size_t nmemb, void *userp)
{
	struct PlFileUploader::TaskInfo* data = (struct PlFileUploader::TaskInfo*)userp;
	if (size * nmemb < 1){
		return 0;
	}
	if(data->size > 0){
		*(char*)ptr = data->tmpbuf[0];
		data->tmpbuf++;
		data->size--;
		return 1;
	}
	return 0;
}

static size_t put_read_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
	size_t retcode;
	retcode = fread(ptr, size, nmemb, (FILE*)stream);
	CCLOG("*****read %ld bytes from file\n", retcode);
	return retcode;
}

PlFileUploader* PlFileUploader::_fileUploader = nullptr;

PlFileUploader* PlFileUploader::getInstance()
{
	if(!_fileUploader){
		_fileUploader = new PlFileUploader();
		_fileUploader->initCurl();
	}


	return _fileUploader;
}

PlFileUploader::PlFileUploader()
{
	_curl = nullptr;
	_uploadThread = nullptr;
	_curTask = nullptr;
	_filegetter = nullptr;
	_onLuaGetreturn = 0;
	_onLuaPutreturn = 0;
}

PlFileUploader::~PlFileUploader()
{
	CCLOG("PlFileUploader::~PlFileUploader()\n");
	if (_curl){
		curl_easy_cleanup(_curl);
	}
#ifdef WIN32
	curl_global_cleanup();
#endif
	if(_filegetter){
		_filegetter->notifyQuit();
		_filegetter->release();
		_filegetter = nullptr;
	}
	
	if(_onLuaPutreturn)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaPutreturn);
	if(_onLuaGetreturn)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaGetreturn);

}

bool PlFileUploader::initCurl()
{
	CURLcode  res;
#ifdef WIN32
	res = curl_global_init(CURL_GLOBAL_DEFAULT);
	if (res != CURLE_OK){
		CCLOG("curl_global_init() failed:%s\n", curl_easy_strerror(res));
		return false;
	}	
#endif

	_curl = curl_easy_init();
	if(!_curl){
		CCLOG("curl_easy_init() failed.\n");
		return false;
	}

	curl_easy_setopt(_curl, CURLOPT_POST, 1);
	curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, 10);
	curl_easy_setopt(_curl, CURLOPT_FOLLOWLOCATION, 1);
	return true;
}

bool PlFileUploader::initFilegetter(){
	if(!_filegetter){
		_filegetter = new PlFileLoader();
		bool ret = _filegetter->init();
		if(ret){
			_filegetter->_onLuaTaskReturn = _onLuaGetreturn;
		}
		return ret;
	}
	return true;
}

bool PlFileUploader::upload(const char* serverpath, const char* filename)
{
	if (_uploadThread == nullptr){
		_uploadThread = new std::thread(&PlFileUploader::uploader, this);
		_uploadThread->detach();
	}

	TaskInfo* task = new TaskInfo();
	task->serverpath = serverpath;
	task->filename = filename;

	_taskInfoQueueMutex.lock();
	_taskInfoQueue.push(task);
	_taskInfoQueueMutex.unlock();

	wakeUp();
	return true;
}

void PlFileUploader::setCallback(int onput, int onget)
{
	if(_onLuaPutreturn)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaPutreturn);
	if(_onLuaGetreturn)
		LuaEngine::getInstance()->removeScriptHandler(_onLuaGetreturn);

	_onLuaPutreturn = onput;
	_onLuaGetreturn = onget;
	if(_filegetter){
		_filegetter->_onLuaTaskReturn = onget;
	}
}

void PlFileUploader::setPutTimeout(int timeout)
{
	if(_curl){
		curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, timeout);
	}
}

bool PlFileUploader::getFile(const char* url, const char* saveName)
{
	bool ret = initFilegetter();
	if (ret){
		PlFileLoader::TaskInfo* task = new PlFileLoader::TaskInfo();
		task->opType = PlFileLoader::TYPE_DOWNlOAD;
		task->needProgress = false;
		task->storgePath = "";
		task->fileName = saveName;
		task->url = url;
		task->startPos = 0;
		bool ok = _filegetter->performTask(task);
		if (!ok){
			delete task;
			return false;
		}
		return true;
	}
	return false;
}

void PlFileUploader::wakeUp()
{
	_sleepCondition.notify_one();
}

void PlFileUploader::waitforCondition()
{
	std::unique_lock<std::mutex> lk(_sleepMutex);
	_sleepCondition.wait(lk);
}

void PlFileUploader::uploader()
{
	CCLOG("PlFileUploader thread start............\n");
	this->retain();

	for(;;){
		_taskInfoQueueMutex.lock();
		if(! _taskInfoQueue.empty()){
			_curTask = _taskInfoQueue.front();
			_taskInfoQueue.pop();
		}
		_taskInfoQueueMutex.unlock();
		if (_curTask){
			doPutTask();
			delete _curTask;
			_curTask = nullptr;
		}else{
			waitforCondition();
		}
	}
	this->release();
}

void PlFileUploader::doPostTask()
{
	CURLcode res;
	struct curl_slist *chunk = NULL;
	ssize_t size = 0;
	unsigned char* buf = FileUtils::getInstance()->getFileData(_curTask->filename.c_str(), "rb+", &size);
	if(!buf){
		CCLOG("doTask() failed: not readfile:%s\n", _curTask->filename.c_str());
		return;
	}
	_curTask->buf = buf;
	_curTask->tmpbuf = buf;
	_curTask->size = size;
	curl_easy_setopt(_curl,  CURLOPT_READFUNCTION, post_read_callback);
	curl_easy_setopt(_curl, CURLOPT_READDATA, _curTask);
#ifdef USE_CHUNKED
	{
		chunk = curl_slist_append(chunk, "Transfer-Encoding: chunked");
		res = curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
	}	
#else
	curl_easy_setopt(_curl, CURLOPT_POSTFIELDSIZE, _curTask->size);
#endif

#ifdef DISABLE_EXPECT
	{ 
      chunk = curl_slist_append(chunk, "Expect:");
      res = curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
      /* use curl_slist_free_all() after the *perform() call to free this
         list again */ 
    }
#endif
	res = curl_easy_perform(_curl);
	if(res != CURLE_OK){
		CCLOG("curl_easy_perform() failed:%s\n", curl_easy_strerror(res));
	}
	curl_slist_free_all(chunk);
}

void PlFileUploader::doPutTask()
{
	CURLcode res;
	FILE* fd = nullptr;
	fd = fopen(_curTask->filename.c_str(), "rb");
	if(!fd){
		CCLOG("doPutTask() failed: can not read file:%s\n", _curTask->filename.c_str());
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([this]{
			this->onTaskReturn(false, "nofile");
		});	
		return;
	} 
	long len = PlFileLoader::getFileLength(_curTask->filename.c_str());
	curl_easy_setopt(_curl,  CURLOPT_READFUNCTION, put_read_callback);
	curl_easy_setopt(_curl, CURLOPT_UPLOAD, 1);
	curl_easy_setopt(_curl, CURLOPT_PUT, 1L);

	curl_easy_setopt(_curl, CURLOPT_URL, _curTask->serverpath.c_str());
	curl_easy_setopt(_curl, CURLOPT_READDATA, fd);
	/* provide the size of the upload, we specicially typecast the value
       to curl_off_t since we must be sure to use the correct data size */ 
    curl_easy_setopt(_curl, CURLOPT_INFILESIZE_LARGE,
                     (curl_off_t)len);

	res = curl_easy_perform(_curl);
	if(res != CURLE_OK){
		CCLOG("curl_easy_perform() failed ;%s\n", curl_easy_strerror(res));
	}

	fclose(fd);
	bool ok = (res == CURLE_OK);
	Director::getInstance()->getScheduler()->performFunctionInCocosThread([ok, this]{
		this->onTaskReturn(ok, "");
	});
}

void PlFileUploader::onTaskReturn(bool ok, std::string err)
{
	if(_onLuaPutreturn){
		auto defaultEngine = LuaEngine::getInstance();
		if(defaultEngine){
			LuaStack* stack = defaultEngine->getLuaStack();
			stack->pushObject(this, "cc.PlFileUploader");
			stack->pushBoolean(ok);
			stack->executeFunctionByHandler(_onLuaPutreturn, 2);
		}
	}
}