/****************************************************************************
 Copyright (c) 2013 cocos2d-x.org
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#include "SegLoader.h"
#include "cocos2d.h"

#include <curl/curl.h>
#include <curl/easy.h>
#include <stdio.h>
#include <vector>
//#include <io.h>
#include <thread>
#include "MessageDispatcher.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
#include <io.h>
#endif
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8) && (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <dirent.h>
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include "platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <jni.h>
#endif

#include "unzip.h"
#define KEY_OF_SEG   "current-seg-ver"

using namespace cocos2d;
using namespace std;


#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

#define LOW_SPEED_LIMIT 1L
#define LOW_SPEED_TIME 5L

//extern long  GetLocalFileLenth(const char* fileName); 
//extern long getDownloadFileLenth(const char *url);


//long getSegDownloadFileLenth(const char *url){
//	double  downloadFileLenth = 0;
//	CURL *handle = curl_easy_init();
//	curl_easy_setopt(handle, CURLOPT_URL, url);
//	curl_easy_setopt(handle, CURLOPT_HEADER, 1);    //只需要header头
//	curl_easy_setopt(handle, CURLOPT_NOBODY, 1);    //不需要body
//	if (curl_easy_perform(handle) == CURLE_OK)
//	{
//		curl_easy_getinfo(handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &downloadFileLenth);
//	}
//	else
//	{
//		downloadFileLenth = -1;
//	}
//	curl_easy_cleanup(handle);
//	return downloadFileLenth;
//}



static std::string keyWithHash( const char* prefix, const std::string& url )
{
	char buf[256];
	sprintf(buf,"%s%zd",prefix,std::hash<std::string>()(url));
	CCLOG("%s",buf);
	return buf;
}

static long GetLocalFileLenth(const char* fileName)
{
	//char strTemp[256] = {0};
	//strcpy_s(strTemp,fileName);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
	FILE* fp = fopen(fileName, "rb");
	if(fp != NULL)
	{
		long localLen = _filelength(_fileno(fp));
		fclose(fp);
		return localLen;
	}
	return 0;
#else
	long file_size ;
	FILE* fp = fopen(fileName, "rb");
	if(fp != NULL)
	{
		if(fseek( fp, 0, SEEK_END )==0)
		{
			file_size = ftell( fp );
			fclose(fp);
			return file_size;
		}
		else
		{
			fclose(fp);
			return 0;
		}
	}
	return 0;



#endif
}

 long SegLoader::getDownloadFileLenth(const char *url)
 {
	double downloadFileLenth = 0;
	_curl = curl_easy_init();
	curl_easy_setopt(_curl, CURLOPT_URL, url);
	curl_easy_setopt(_curl, CURLOPT_HEADER, 1);    //只需要header头
	curl_easy_setopt(_curl, CURLOPT_NOBODY, 1);    //不需要body
	if (curl_easy_perform(_curl) == CURLE_OK)
	{
		curl_easy_getinfo(_curl, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &downloadFileLenth);
	}
	else
	{
		downloadFileLenth = -1;
	}
	curl_easy_cleanup(_curl);
	return downloadFileLenth;
}

//long GetLocalFileLenth(const char* fileName)
//{
//	char strTemp[256] = {0};
//	strcpy_s(strTemp,fileName);
//	FILE* fp = fopen(strTemp, "rb");
//	if(fp != NULL)
//	{
//		long localLen = _filelength(_fileno(fp));
//		fclose(fp);
//		return localLen;
//	}
//	return 0;
//}
//
//long getDownloadFileLenth(const char *url){
//	long downloadFileLenth = 0;
//	CURL *handle = curl_easy_init();
//	curl_easy_setopt(handle, CURLOPT_URL, url);
//	curl_easy_setopt(handle, CURLOPT_HEADER, 1);    //只需要header头
//	curl_easy_setopt(handle, CURLOPT_NOBODY, 1);    //不需要body
//	if (curl_easy_perform(handle) == CURLE_OK)
//	{
//		curl_easy_getinfo(handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &downloadFileLenth);
//	}
//	else
//	{
//		downloadFileLenth = -1;
//	}
//	curl_easy_cleanup(handle);
//	return downloadFileLenth;
//}

//bool downLoad(void *_curl, std::string _packageUrl, std::string _storagePath, std::string fileName )
//{
//	// Create a file to save package.
//	const string outFileName = _storagePath + fileName;
//	//================断点续载===================
//	long localLen = GetLocalFileLenth(outFileName.c_str());
//
//	FILE *fp = fopen(outFileName.c_str(), "a+b");
//	if (! fp)
//	{
//		return false;
//	}
//	fseek(fp, 0, SEEK_END);
//
//	// Download pacakge
//	CURLcode res;
//	curl_easy_setopt(_curl, CURLOPT_URL, _packageUrl.c_str());
//	curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadPackage);
//	curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
//	curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
//	curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, assetsManagerProgressFunc);
//	curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
//	curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, 1L);
//	curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, 5L);
//
//	curl_easy_setopt(_curl, CURLOPT_HEADER, 0L);
//	curl_easy_setopt(_curl, CURLOPT_NOBODY, 0L);
//	curl_easy_setopt(_curl, CURLOPT_FOLLOWLOCATION, 1L);
//	curl_easy_setopt(_curl, CURLOPT_RESUME_FROM, localLen);
//
//	curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, &localLen);
//
//
//
//	res = curl_easy_perform(_curl);
//	curl_easy_cleanup(_curl);
//	if (res != 0)
//	{
//		fclose(fp);
//		return false;
//	}
//
//	fclose(fp);
//	return true;
//}



SegLoader::SegLoader()
{
    _isDownloading = false;
	//started = detached = false;
}

SegLoader::~SegLoader()
{
	//stop();
}

//void SegLoader::stop(){
//	if (started && !detached) { 
//		CCLOG("stop");
//		//pthread_cancel(handle);
//		//pthread_detach(handle); 
//		detached = true; 
//	}
//}

void SegLoader::downloadAndInstall()
{


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JavaVM *vm;
	JNIEnv *env;
	vm = JniHelper::getJavaVM();

	JavaVMAttachArgs thread_args;

	thread_args.name = "Resource Load";
	thread_args.version = JNI_VERSION_1_4;
	thread_args.group = NULL;

	vm->AttachCurrentThread(&env, &thread_args);
#endif

	//if(checkURLFileExist(_packageUrl))
		if(true)
	{

		//_packageUrl = url;
		//_storagePath = storagePath;
		//_uncompressPath = uncompressPath;
		checkStoragePath();
		checkUncompressPath();

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
		DIR *pDir = NULL;

		pDir = opendir (_storagePath.c_str());
		if (! pDir)
		{
			mkdir(_storagePath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
		}

		pDir = opendir (_uncompressPath.c_str());
		if (! pDir)
		{
			mkdir(_uncompressPath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
		}
#else
		if ((GetFileAttributesA(_storagePath.c_str())) == INVALID_FILE_ATTRIBUTES)
		{
			CreateDirectoryA(_storagePath.c_str(), 0);
		}

		if ((GetFileAttributesA(_uncompressPath.c_str())) == INVALID_FILE_ATTRIBUTES)
		{
			CreateDirectoryA(_uncompressPath.c_str(), 0);
		}
#endif

		do 
		{

			//Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			//	MessageDispatcher::getInstance()->notifySegLoadStatus(0);
			//});
			if ( downLoad())
			{



				bool result = uncompress();
				string outFileName = _storagePath + "s3arpgseg.zip";
				if (remove(outFileName.c_str()) != 0)
				{
					CCLOG("can not remove s3arpgseg.zip file %s", outFileName.c_str());
				}

				if (! result)
				{
					Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
						MessageDispatcher::getInstance()->notifySegLoadStatus(4);
					});
				}
				else
				{

					Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
						MessageDispatcher::getInstance()->notifySegLoadStatus(0);
					});
				}


			}


		}
		while(0);



	}
	else
	{
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			this->keyOfVersion();
			MessageDispatcher::getInstance()->notifySegLoadStatus(3);
		});
	}


	

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	vm->DetachCurrentThread();
//#else
//	struct timeval timeoutse={2147483647,0};
//	select(0, NULL, NULL, NULL, &timeoutse);
#endif
	_isDownloading = false;
}

//void* SegLoader::downloadAndInstall(void *arg)
//{
//    SegLoader* thred=(SegLoader*)arg;	
//	do 
//	{
//	
//	if ( thred->downLoad())
//	{
//		bool result = thred->uncompress();
//		string outFileName = thred->_storagePath + "s3arpgseg.zip";
//		if (remove(outFileName.c_str()) != 0)
//		{
//			CCLOG("can not remove s3arpgseg.zip file %s", outFileName.c_str());
//		}
//
//		if (! result)
//		{
//			Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
//				MessageDispatcher::getInstance()->notifySegLoadStatus(4);
//			});
//		}
//		else
//		{
//
//			Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
//				MessageDispatcher::getInstance()->notifySegLoadStatus(0);
//			});
//		}
//
//		
//	}
//	
//}
//while(0);
//    thred->_isDownloading = false;
//
//	//while (1);
//
//	return NULL;
//	
//}

void SegLoader::checkStoragePath()
{
	if (_storagePath.size() > 0 && _storagePath[_storagePath.size() - 1] != '/')
	{
		_storagePath.append("/");
	}
}

	void SegLoader::checkUncompressPath()
{
	if (_uncompressPath.size() > 0 && _uncompressPath[_uncompressPath.size() - 1] != '/')
	{
		_uncompressPath.append("/");
	}
}

static size_t  processdatatemp(void *buffer, size_t size, size_t nmemb, void *user_p)
{
	return nmemb;
}

//void * SegLoader::getCurl()
//{
//	return _curl;
//}

bool SegLoader::checkURLFileExist(std::string &path)
{
	_curl = curl_easy_init();
	if (! _curl)
	{
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			this->keyOfVersion();
			MessageDispatcher::getInstance()->notifySegLoadStatus(2);
		});
		CCLOG("can not init curl");
		return false;
	}
	// 设置本次会话的参数
	// URL，就是我们要验证的网址
	curl_easy_setopt(_curl,CURLOPT_URL,path.c_str());
	// 设置连接超时
	curl_easy_setopt(_curl,CURLOPT_CONNECTTIMEOUT,5);
	// 只是获取HTML的header
	curl_easy_setopt(_curl,CURLOPT_HEADER,true);
	curl_easy_setopt(_curl,CURLOPT_NOBODY,true);
	// 设置最大重定向数为0，不允许页面重定向
	curl_easy_setopt(_curl,CURLOPT_MAXREDIRS,0);
	// 设置一个空的写入函数，屏蔽屏幕输出
	curl_easy_setopt(_curl,CURLOPT_WRITEFUNCTION,&processdatatemp);
	// 以上面设置的参数执行这个会话，向服务器发起请求
	curl_easy_perform(_curl);
	// 获取HTTP的状态代码
	// 根据代码判断网址是否有效
	long retcode = 0;
	curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE , &retcode);
	bool res = false;
	// 如果HTTP反应代码为200，表示网址有效
	if(200 == retcode)
	{
		res = true;
	}
	// 执行会话的清理工作
	curl_easy_cleanup(_curl);
	return res;
}

void SegLoader::startDownload(std::string url,std::string storagePath,std::string uncompressPath)
{
    if (_isDownloading) return;

	CCLOG("startDownload url=%s   storagePath = %s  uncompressPath=%s",url.c_str(),storagePath.c_str(),uncompressPath.c_str());
    
    _isDownloading = true;
	_packageUrl = url;
	_storagePath = storagePath;
	_uncompressPath = uncompressPath;

	auto t = std::thread(&SegLoader::downloadAndInstall, this);
	t.detach();

	/*

	if(checkURLFileExist(url))
	{
    
	_packageUrl = url;
	_storagePath = storagePath;
	_uncompressPath = uncompressPath;
	checkStoragePath();
	checkUncompressPath();

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *pDir = NULL;

	pDir = opendir (_storagePath.c_str());
	if (! pDir)
	{
		mkdir(_storagePath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
	}

	pDir = opendir (_uncompressPath.c_str());
	if (! pDir)
	{
		mkdir(_uncompressPath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
	}
#else
	if ((GetFileAttributesA(_storagePath.c_str())) == INVALID_FILE_ATTRIBUTES)
	{
		CreateDirectoryA(_storagePath.c_str(), 0);
	}

	if ((GetFileAttributesA(_uncompressPath.c_str())) == INVALID_FILE_ATTRIBUTES)
	{
		CreateDirectoryA(_uncompressPath.c_str(), 0);
	}
#endif
    // Is package already downloaded?
  //  _downloadedVersion = UserDefault::getInstance()->getStringForKey(keyOfDownloadedVersion().c_str());
    
    auto t = std::thread(&SegLoader::downloadAndInstall, this);
    t.detach();

	//int errCode = 0;
	//do{
	//	pthread_attr_t attributes;
	//	errCode = pthread_attr_init(&attributes);
	//	CC_BREAK_IF(errCode!=0);
	//	errCode = pthread_attr_setdetachstate(&attributes, PTHREAD_CREATE_DETACHED);
	//	if (errCode!=0) {
	//		pthread_attr_destroy(&attributes);
	//		//break;
	//		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
	//			MessageDispatcher::getInstance()->notifySegLoadStatus(5);
	//		});


	//	}		
	//	errCode = pthread_create(&handle, &attributes,downloadAndInstall,this);

	//}while (0);



	}
	else
	{
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			this->keyOfVersion();
			MessageDispatcher::getInstance()->notifySegLoadStatus(3);
		});
	}
	*/
}

SegLoader* SegLoader::getInstance()
{
	static SegLoader* instance = NULL;

	if(instance == NULL) 
	{
		instance = new SegLoader();
		instance->isStop = false;
		instance->downloadingspeed = 1024000;
		instance->currentspeed = instance->downloadingspeed;



	}
	return instance;
}


static size_t downLoadPackage(void *ptr, size_t size, size_t nmemb, void *userdata)
{
    FILE *fp = (FILE*)userdata;
	/*if (size == 1 && nmemb<512)
	{
		char *pp = new char(nmemb+1);
		memcpy(pp,(char *)ptr,nmemb);
		pp[nmemb] = 0;
		CCLOG("downLoadPackage %d   %d     %s",size, nmemb,pp);
		delete pp;
	}*/
	
	//CCLOG("downLoadPackage %d   %d",size, nmemb);
	size_t written = 0;
	if (ptr!=NULL)
	{
     written = fwrite(ptr, size, nmemb, fp);
	}
	//SegLoader* sl = SegLoader::getInstance();
	////SegLoader* sl = MessageDispatcher::getInstance()->getSegLoader();
	//	if (sl!=NULL)
	//	{
	//		
	//			if(sl->isStop){
	//				curl_easy_pause(sl->_curl, CURLPAUSE_RECV);
	//			}else{
	//				curl_easy_pause(sl->_curl, CURLPAUSE_CONT);
	//			}
	//	}
		

		return written;
	
}

static int zipDownloadingProgressFunc1(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
    static int percent = 0;

	SegLoader* sl = SegLoader::getInstance();
	//SegLoader* sl = MessageDispatcher::getInstance()->getSegLoader();
	if (sl!=NULL)
	{

		if(sl->isStop){
			curl_easy_pause(sl->_curl, CURLPAUSE_RECV);
		}else{
			curl_easy_pause(sl->_curl, CURLPAUSE_CONT);
		}

		if (sl->downloadingspeed!=sl->currentspeed)
		{
			sl->currentspeed = sl->downloadingspeed;
			curl_easy_setopt(sl->_curl, CURLOPT_MAX_RECV_SPEED_LARGE,(curl_off_t)(sl->currentspeed)); 
		}
		
	}

	//CCLOG("downloading... %f%f%", nowDownloaded,totalToDownload);
	if((int)totalToDownload == 0)
	{
		return 0;
	}
	//int tmp = (int)(nowDownloaded / totalToDownload * 100);
	int tmp =0;


	long localLen = *(long*)ptr;
	if ( totalToDownload > 0 )
	{
		tmp = (int)((nowDownloaded + (double)localLen) / (totalToDownload + (double)localLen) * 100);
	}

    
    if (percent != tmp)
    {
        percent = tmp;
        Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
			MessageDispatcher::getInstance()->notifySegLoading((totalToDownload + (double)localLen),(nowDownloaded + (double)localLen),percent);
        });
        
        CCLOG("downloading... %d%%", percent);
    }
    
    return 0;
}


int zipDownloadingProgressFunc2(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	static int percent = 0;

	SegLoader* sl = SegLoader::getInstance();
	//SegLoader* sl = MessageDispatcher::getInstance()->getSegLoader();
	if (sl!=NULL)
	{

		if(sl->isStop){
			curl_easy_pause(sl->_curl, CURLPAUSE_RECV);
		}else{
			curl_easy_pause(sl->_curl, CURLPAUSE_CONT);
		}

		if (sl->downloadingspeed!=sl->currentspeed)
		{
			sl->currentspeed = sl->downloadingspeed;
			curl_easy_setopt(sl->_curl, CURLOPT_MAX_RECV_SPEED_LARGE,(curl_off_t)(sl->currentspeed)); 
		}
	}
	//CCLOG("downloading... %f%f%", nowDownloaded,totalToDownload);
	if((int)totalToDownload == 0)
	{
		return 0;
	}
	int tmp = (int)(nowDownloaded / totalToDownload * 100);
	

	if (percent != tmp)
	{
		percent = tmp;
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
			MessageDispatcher::getInstance()->notifySegLoading(totalToDownload,nowDownloaded,percent);
		});

		CCLOG("downloading... %d%%", percent);
	}

	return 0;
}

bool SegLoader::createDirectory(const char *path)
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



bool SegLoader::uncompress()
{
	// Open the zip file
	string outFileName = _storagePath + "s3arpgseg.zip";
	unzFile zipfile = unzOpen(outFileName.c_str());
	if (! zipfile)
	{
		CCLOG("can not open downloaded zip file %s", outFileName.c_str());
		return false;
	}

	// Get info about the zip file
	unz_global_info global_info;
	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLOG("can not read file global info of %s", outFileName.c_str());
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

		const string fullPath = _uncompressPath + fileName;

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
			const string fileNameStr(fileName);

			size_t startIndex=0;

			size_t index=fileNameStr.find("/",startIndex);

			while(index != std::string::npos)
			{
				const string dir=_uncompressPath+fileNameStr.substr(0,index);

				FILE *out = fopen(dir.c_str(), "r");

				if(!out)
				{
					if (!createDirectory(dir.c_str()))
					{
						CCLOG("can not create directory %s", dir.c_str());
						unzClose(zipfile);
						return false;
					}
					else
					{
						CCLOG("create directory %s",dir.c_str());
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


std::string SegLoader::keyOfVersion() const
{
	return keyWithHash(KEY_OF_SEG,MessageDispatcher::getInstance()->callBackForLua(1,""));
}

bool SegLoader::downLoad()
{

	
	// Create a file to save package.
	const string outFileName = _storagePath + "s3arpgseg.zip";
	CURLcode res;
	FILE *fp = NULL;
	long localLen = 0;
	bool reloader = false;
	long olen = 0;
	if (_packageUrl==UserDefault::getInstance()->getStringForKey(keyOfVersion().c_str()))
	{
		localLen = GetLocalFileLenth(outFileName.c_str());
		CCLOG("GetLocalFileLenth = %d",localLen);
		fp = fopen(outFileName.c_str(), "a+b");
	}
	if ( fp)
	{
		olen = getDownloadFileLenth(_packageUrl.c_str());
		if (olen==localLen)
		{
		  fclose(fp);
		  return true;
		}
		else if (olen<localLen)
		{
			fclose(fp);
			reloader = true;
		}
		else
		{
			reloader = false;
		}
	}
	else
	{
		reloader = true;
	}
	
	
	if (reloader)
	{
		if (fp)
		{
			fclose(fp);
		}
		fp = fopen(outFileName.c_str(), "wb");
		if (! fp)
		{
			Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
				this->keyOfVersion();
				MessageDispatcher::getInstance()->notifySegLoadStatus(1);
			});
			CCLOG("can not create file %s", outFileName.c_str());
			return false;
		}
		else
		{
			_curl = curl_easy_init();
			if (! _curl)
			{
				Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
					this->keyOfVersion();
					MessageDispatcher::getInstance()->notifySegLoadStatus(2);
				});
				fclose(fp);
				CCLOG("can not init curl");
				return false;
			}

			// Download pacakge
			 UserDefault::getInstance()->setStringForKey(this->keyOfVersion().c_str(), _packageUrl);
			curl_easy_setopt(_curl, CURLOPT_URL, _packageUrl.c_str());
			curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadPackage);
			curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
			curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
			curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, zipDownloadingProgressFunc2);
			curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, this);
			curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
			curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, LOW_SPEED_LIMIT);
			curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, LOW_SPEED_TIME);
			curl_easy_setopt(_curl, CURLOPT_MAX_RECV_SPEED_LARGE,(curl_off_t) 1024000); 

			res = curl_easy_perform(_curl);
			curl_easy_cleanup(_curl);
			if (res != 0)
			{
				Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
					this->keyOfVersion();
					MessageDispatcher::getInstance()->notifySegLoadStatus(2);
				});
				CCLOG("error when download package");
				fclose(fp);
				return false;
			}

			CCLOG("succeed downloading package %s", _packageUrl.c_str());

			fclose(fp);
			return true;
		}
	}
	else
	{
		
		fseek(fp, 0, SEEK_END);
		_curl = curl_easy_init();
		if (! _curl)
		{
			Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
				this->keyOfVersion();
				MessageDispatcher::getInstance()->notifySegLoadStatus(2);
			});
			fclose(fp);
			CCLOG("can not init curl");
			return false;
		}
		// Download pacakge
		UserDefault::getInstance()->setStringForKey(this->keyOfVersion().c_str(), _packageUrl);
		curl_easy_setopt(_curl, CURLOPT_URL, _packageUrl.c_str());
		curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadPackage);
		curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
		curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
		curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, zipDownloadingProgressFunc1);
		curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
		curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, 1L);
		curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, 5L);
		curl_easy_setopt(_curl, CURLOPT_MAX_RECV_SPEED_LARGE,(curl_off_t) 1024000); 

		curl_easy_setopt(_curl, CURLOPT_HEADER, 0L);
		curl_easy_setopt(_curl, CURLOPT_NOBODY, 0L);
		curl_easy_setopt(_curl, CURLOPT_FOLLOWLOCATION, 1L);
		curl_easy_setopt(_curl, CURLOPT_RESUME_FROM, localLen);

		curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, &localLen);



		res = curl_easy_perform(_curl);
		curl_easy_cleanup(_curl);
		if (res != 0)
		{
			
			Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
				this->keyOfVersion();
				MessageDispatcher::getInstance()->notifySegLoadStatus(2);
			});
			CCLOG("error when download package %d",res);
			fclose(fp);
			return false;
		}

		CCLOG("resucceed downloading package %s", _packageUrl.c_str());
		fclose(fp);
		return true;
	}
	




    

    
    
	
}



