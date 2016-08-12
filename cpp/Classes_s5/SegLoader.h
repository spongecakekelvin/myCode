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

#ifndef __SEG_LOADER__
#define __SEG_LOADER__

#include "cocos2d.h"

//#include "pthread.h"

/*
 *  This class is used to auto update resources, such as pictures or scripts.
 *  The updated package should be a zip file. And there should be a file named
 *  version in the server, which contains version code.
 */
class SegLoader : public cocos2d::Node
{

public:
	static SegLoader* getInstance();
public:
    SegLoader();
    virtual ~SegLoader();
    void *_curl;
	
	void startDownload(std::string url,std::string storagePath,std::string uncompressPath);
	//void * SegLoader::getCurl();
	bool isStop;
	int downloadingspeed;
	int currentspeed;
	//void stop();

protected:
    bool downLoad();
	bool uncompress();
    void checkStoragePath();
	bool createDirectory(const char *path);

	//static void* downloadAndInstall(void *);
	 void downloadAndInstall();
	bool checkURLFileExist(std::string &path);
	void checkUncompressPath();
	 long getDownloadFileLenth(const char *url);
	 
	
private:
    //! The path to store downloaded resources.
	
	std::string _uncompressPath;
		std::string _packageUrl;
    std::string keyOfVersion() const;
    
	bool _isDownloading;
	std::string _storagePath;
    

		//pthread_t handle; 
	//bool started;
	//bool detached;
    
};


#endif /* defined(__AssetsManager__) */
