#ifndef  __PLFILEUPLOADER_H__
#define  __PLFILEUPLOADER_H__

#include "PlFileLoader.h"

class PlFileUploader : public Ref{
public:
	struct TaskInfo {
		std::string serverpath;
		std::string filename;
		unsigned char* buf;
		unsigned char* tmpbuf;
		ssize_t size;
	};
public:
	static PlFileUploader* getInstance();
	PlFileUploader();
	~PlFileUploader();

	bool upload(const char* serverpath, const char* filename);
	bool getFile(const char* url, const char* saveName);
	void setCallback(int onput, int onget);
	void setPutTimeout(int timeout);	

	void uploader();
	void wakeUp();
	void waitforCondition();
	void doPostTask();
	void doPutTask();
	bool initCurl();
	bool initFilegetter();
	void onTaskReturn(bool ok, std::string err);
public:
	void * _curl;
private:
	static PlFileUploader* _fileUploader;
	std::thread* _uploadThread;

	std::mutex _sleepMutex;
	std::condition_variable _sleepCondition;
	std::queue<TaskInfo*> _taskInfoQueue;
	std::mutex _taskInfoQueueMutex;

	/////for get file
	PlFileLoader* _filegetter;
	TaskInfo* _curTask;
	int _onLuaPutreturn;
	int _onLuaGetreturn;
};
#endif