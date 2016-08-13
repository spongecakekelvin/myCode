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

#ifndef __UpgradeApk__
#define __UpgradeApk__

#include "cocos2d.h"



/*
 *  This class is used to auto update resources, such as pictures or scripts.
 *  The updated package should be a zip file. And there should be a file named
 *  version in the server, which contains version code.
 */
class UpgradeApk : public cocos2d::Node
{

public:
	static UpgradeApk* getInstance();
public:
    UpgradeApk();
    virtual ~UpgradeApk();
    

	void startDownload(std::string url,std::string storagePath);


protected:
    bool downLoad();
    void checkStoragePath();
    void downloadAndInstall();
	bool checkURLFileExist(std::string &path);

    
private:
    //! The path to store downloaded resources.
	std::string _storagePath;
		std::string _packageUrl;
    std::string keyOfVersion() const;
    void *_curl;
    
    bool _isDownloading;
    
};


#endif /* defined(__AssetsManager__) */
