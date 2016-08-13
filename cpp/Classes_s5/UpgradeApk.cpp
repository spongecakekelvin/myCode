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
#include "UpgradeApk.h"
#include "cocos2d.h"

#include <curl/curl.h>
#include <curl/easy.h>
#include <stdio.h>
#include <vector>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
#include <io.h>
#endif
#include <thread>
#include "MessageDispatcher.h"

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

using namespace cocos2d;
using namespace std;


#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

#define LOW_SPEED_LIMIT 1L
#define LOW_SPEED_TIME 5L
#define KEY_OF_APK   "now-apk-version"

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

static long getDownloadFileLenth(const char *url){
	double downloadFileLenth = 0;
	CURL *handle = curl_easy_init();
	curl_easy_setopt(handle, CURLOPT_URL, url);
	curl_easy_setopt(handle, CURLOPT_HEADER, 1);    //只需要header头
	curl_easy_setopt(handle, CURLOPT_NOBODY, 1);    //不需要body
	if (curl_easy_perform(handle) == CURLE_OK)
	{
		curl_easy_getinfo(handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &downloadFileLenth);
	}
	else
	{
		downloadFileLenth = -1;
	}
	curl_easy_cleanup(handle);
	return downloadFileLenth;
}

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



UpgradeApk::UpgradeApk()
{
	_isDownloading = false;
}

UpgradeApk::~UpgradeApk()
{
}

//
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//typedef enum _GET_JNIENV_STATUS{
//	GET_FAIL = 0,
//	GET_SUCCES_NOATTACH,
//	GET_SUCCES_ATTCH,
//}Get_JNIEnv_Status;
//
//
//static Get_JNIEnv_Status getJNIEnv(JavaVM *myVm,JNIEnv *env)
//{
//	Get_JNIEnv_Status GetStatus = GET_FAIL;  
//	int status = myVm->GetEnv((void **) &env, JNI_VERSION_1_4);  
//
//	if(status < 0) {  
//		//LOGD("callback_handler:failed to get JNI environment assuming native thread");   
//		status = myVm->AttachCurrentThread(&env, NULL);  
//		if(status < 0) {  
//			//LOGE("callback_handler: failed to attach current thread");  
//			return GetStatus;  
//		}  
//		GetStatus = GET_SUCCES_ATTCH;  
//	}
//	else
//	{
//		GetStatus = GET_SUCCES_NOATTACH;
//	}
//	return GetStatus;
//}
//#endif

void UpgradeApk::downloadAndInstall()
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

		checkStoragePath();

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
		DIR *pDir = NULL;

		pDir = opendir (_storagePath.c_str());
		if (! pDir)
		{
			mkdir(_storagePath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
		}
#else
		if ((GetFileAttributesA(_storagePath.c_str())) == INVALID_FILE_ATTRIBUTES)
		{
			CreateDirectoryA(_storagePath.c_str(), 0);
		}
#endif
		// Is package already downloaded?
		//  _downloadedVersion = UserDefault::getInstance()->getStringForKey(keyOfDownloadedVersion().c_str());

		do
		{
			if ( downLoad())
			{


				Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
					MessageDispatcher::getInstance()->changeFileMod(_storagePath + "s3arpg.apk");
					MessageDispatcher::getInstance()->notifyApkLoadStatus(0);
				});

			}
		}
		while(0);
	}
	else
	{
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			MessageDispatcher::getInstance()->notifyApkLoadStatus(3);
		});
	}




	
	//struct timeval timeoutse={2147483647,0};
	//select(0, NULL, NULL, NULL, &timeoutse);
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	vm->DetachCurrentThread();
	/*if (GET_SUCCES_ATTCH ==getJNIEnv(vm,env))
	{
		vm->DetachCurrentThread();
		CCLOG("DetachCurrentThread");
	}
	else
	{
		CCLOG("do not DetachCurrentThread");
	}*/
	
	//#else
	//	struct timeval timeoutse={2147483647,0};
	//	select(0, NULL, NULL, NULL, &timeoutse);
#endif
	_isDownloading = false;
	//struct timeval timeoutse={2147483647,0};
	//select(0, NULL, NULL, NULL, &timeoutse);
	
}

void UpgradeApk::checkStoragePath()
{
	if (_storagePath.size() > 0 && _storagePath[_storagePath.size() - 1] != '/')
	{
		_storagePath.append("/");
	}
}

static size_t  processdatatemp(void *buffer, size_t size, size_t nmemb, void *user_p)
{
	return nmemb;
}

bool UpgradeApk::checkURLFileExist(std::string &path)
{
	_curl = curl_easy_init();
	if (! _curl)
	{
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			MessageDispatcher::getInstance()->notifyApkLoadStatus(2);
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

void UpgradeApk::startDownload(std::string url,std::string storagePath)
{
	if (_isDownloading) return;

	CCLOG("startDownload url=%s   storagePath = %s",url.c_str(),storagePath.c_str());

	_isDownloading = true;

	_packageUrl = url;
	_storagePath = storagePath;
	auto t = std::thread(&UpgradeApk::downloadAndInstall, this);
	t.detach();


	/*
	if(checkURLFileExist(url))
	{

		_packageUrl = url;
		_storagePath = storagePath;

		checkStoragePath();

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
		DIR *pDir = NULL;

		pDir = opendir (_storagePath.c_str());
		if (! pDir)
		{
			mkdir(_storagePath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
		}
#else
		if ((GetFileAttributesA(_storagePath.c_str())) == INVALID_FILE_ATTRIBUTES)
		{
			CreateDirectoryA(_storagePath.c_str(), 0);
		}
#endif
		// Is package already downloaded?
		//  _downloadedVersion = UserDefault::getInstance()->getStringForKey(keyOfDownloadedVersion().c_str());

		auto t = std::thread(&UpgradeApk::downloadAndInstall, this);
		t.detach();
	}
	else
	{
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
			MessageDispatcher::getInstance()->notifyApkLoadStatus(3);
		});
	}

	*/
}

UpgradeApk* UpgradeApk::getInstance()
{
	static UpgradeApk* instance = NULL;

	if(instance == NULL) 
	{
		instance = new UpgradeApk();
	}
	return instance;
}


static size_t downLoadPackage(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	FILE *fp = (FILE*)userdata;
	if (ptr !=NULL)
	{
		size_t written = fwrite(ptr, size, nmemb, fp);
		return written;
	}
	
	
		return 0;
	
	
}

int apkDownloadingProgressFunc1(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	static int percent = 0;
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
			MessageDispatcher::getInstance()->notifyApkLoading((totalToDownload + (double)localLen),(nowDownloaded + (double)localLen),percent);
		});

		CCLOG("downloading... %d%%", percent);
	}

	return 0;
}


static int apkDownloadingProgressFunc2(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	static int percent = 0;
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
			MessageDispatcher::getInstance()->notifyApkLoading(totalToDownload,nowDownloaded,percent);
		});

		CCLOG("downloading... %d%%", percent);
	}

	return 0;
}

std::string UpgradeApk::keyOfVersion() const
{
	return keyWithHash(KEY_OF_APK,MessageDispatcher::getInstance()->callBackForLua(1,""));
}

bool UpgradeApk::downLoad()
{
	// Create a file to save package.


	const string outFileName = _storagePath + "s3arpg.apk";
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
				MessageDispatcher::getInstance()->notifyApkLoadStatus(1);
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
					MessageDispatcher::getInstance()->notifyApkLoadStatus(2);
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
			curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, apkDownloadingProgressFunc2);
			curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, this);
			curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
			curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, LOW_SPEED_LIMIT);
			curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, LOW_SPEED_TIME);

			res = curl_easy_perform(_curl);
			curl_easy_cleanup(_curl);
			if (res != 0)
			{
				Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, this]{
					MessageDispatcher::getInstance()->notifyApkLoadStatus(2);
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
				MessageDispatcher::getInstance()->notifyApkLoadStatus(2);
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
		curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, apkDownloadingProgressFunc1);
		curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
		curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, 1L);
		curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, 5L);

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
				MessageDispatcher::getInstance()->notifyApkLoadStatus(2);
			});
			CCLOG("error when download package");
			fclose(fp);
			return false;
		}

		CCLOG("resucceed downloading package %s", _packageUrl.c_str());
		fclose(fp);
		return true;
	}
}



