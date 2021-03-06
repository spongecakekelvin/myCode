# -*- coding: utf-8 -*-
# Author:xiaohei
# CreateTime:2014-10-25
#
# All file operations are defined here
import codecs
import inspect
import os
import os.path
import platform
import re
import stat
import subprocess
import sys
import threading
import time

pythonDir = sys.prefix
curDir = os.getcwd()
#curDir = 'E:\\fusion2\\demos\\_tools'
parent_dir = os.path.dirname(curDir)


def list_files(src, resFiles, igoreFiles):

    if os.path.exists(src):

        if os.path.isfile(src) and src not in igoreFiles:
            resFiles.append(src)
        elif os.path.isdir(src):
            for f in os.listdir(src):
                if src not in igoreFiles:
                    list_files(os.path.join(src, f), resFiles, igoreFiles)

    return resFiles


def del_file_folder(src):
    if os.path.exists(src):
        if os.path.isfile(src):
            try:
                src = src.replace('\\', '/')
                os.remove(src)
            except:
                pass

        elif os.path.isdir(src):
            for item in os.listdir(src):
                itemsrc = os.path.join(src, item)
                del_file_folder(itemsrc)

            try:
                os.rmdir(src)
            except:
                pass


def copy_files(src, dest):
    if not os.path.exists(src):
        log_utils.warning("the src is not exists.path:%s", src)
        return

    if os.path.isfile(src):
        copy_file(src, dest)
        return

    for f in os.listdir(src):
        sourcefile = os.path.join(src, f)
        targetfile = os.path.join(dest, f)
        if os.path.isfile(sourcefile):
            copy_file(sourcefile, targetfile)
        else:
            copy_files(sourcefile, targetfile)


def copy_file(src, dest):
    sourcefile = getFullPath(src)
    destfile = getFullPath(dest)
    if not os.path.exists(sourcefile):
        return
    
    destdir = os.path.dirname(destfile)
    if not os.path.exists(destdir):
        os.makedirs(destdir)
    destfilestream = open(destfile, 'wb')
    sourcefilestream = open(sourcefile, 'rb')
    destfilestream.write(sourcefilestream.read())
    destfilestream.close()
    sourcefilestream.close()

def getFileContent(sourcefile):
    
    if not os.path.exists(sourcefile):
        log_utils.warning("the source is not exists.path:%s", sourcefile)
        return 

    f = open(sourcefile, 'r+')
    data = str(f.read())
    f.close()
    return data
    
def setFileContent(content, dest):
    destfile = getFullPath(dest)
    
    destdir = os.path.dirname(destfile)
    if not os.path.exists(destdir):
        os.makedirs(destdir)
    destfilestream = open(destfile, 'wb')
    destfilestream.write(content)
    destfilestream.close()
    
def modifyFileContent(sourcefile, oldContent, newContent):
    if os.path.isdir(sourcefile):
        log_utils.warning("the source %s must be a file not a dir", sourcefile)
        return

    if not os.path.exists(sourcefile):
        log_utils.warning("the source is not exists.path:%s", sourcefile)
        return 

    f = open(sourcefile, 'r+')
    data = str(f.read())
    f.close()
    bRet = False
    idx = data.find(oldContent)
    while idx != -1:
        data = data[:idx] + newContent + data[idx + len(oldContent):]
        idx = data.find(oldContent, idx + len(oldContent))
        bRet = True

    if bRet:
        fw = open(sourcefile, 'w')
        fw.write(data)
        fw.close()
        log_utils.info("modify file success.path:%s", sourcefile)
    else:
        log_utils.warning("there is no content matched in file:%s with content:%s", sourcefile, oldContent)

def getCurrDir():
    global curDir
    retPath = curDir
    if platform.system() == 'Darwin':
        retPath = sys.path[0]
        lstPath = os.path.split(retPath)
        if lstPath[1]:
            retPath = lstPath[0]

    return retPath


def getFullPath(filename):
    if os.path.isabs(filename):
        return filename
    currdir = curDir
    filename = os.path.join(currdir, filename)
    filename = filename.replace('\\', '/')
    filename = re.sub('/+', '/', filename)
    return filename

def getSplashPath():
    return getFullPath("config/splash")

def getJavaBinDir():
    if platform.system() == 'Windows':
        return getFullPath("tool/win/jre/bin/")
    else:
        return ""

def getJavaCMD():
    return getJavaBinDir() + "java"

def getToolPath(filename):
    if platform.system() == 'Windows':
        return "tool/win/" + filename
    else:
        return "tool/mac/" + filename


def getFullToolPath(filename):
    return getFullPath(getToolPath(filename))

def getFullOutputPath(appName, channel):
    path = getFullPath('output/' + appName + '/' + channel)
    #del_file_folder(path)
    if not os.path.exists(path):
        os.makedirs(path)
    return path


def execFormatCmd(cmd):
    cmd = cmd.replace('\\', '/')
    cmd = re.sub('/+', '/', cmd)
    ret = 0

    try:
        reload(sys)
        sys.setdefaultencoding('utf-8')

        if platform.system() == 'Windows':
            st = subprocess.STARTUPINFO
            st.dwFlags = subprocess.STARTF_USESHOWWINDOW
            st.wShowWindow = subprocess.SW_HIDE
            # cmd = str(cmd).encode('gbk')
        s = subprocess.Popen(cmd, shell=True)
        ret = s.wait()
        if ret:
            s = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            stdoutput, erroutput = s.communicate()

            log_utils.error("*******ERROR*******")
            log_utils.error(stdoutput)
            log_utils.error(erroutput)
            log_utils.error("*******************")

            cmd = 'error::' + cmd + '  !!!exec Fail!!!  '
        else:

            s = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            stdoutput, erroutput = s.communicate()

            log_utils.info(stdoutput)
            log_utils.info(erroutput)

            cmd = cmd + ' !!!exec success!!! '

        log_utils.info(cmd)

    except Exception as e:
        print(e)
        return

    return ret


def execWinCommand(cmd):
    os.system(cmd)  


def execWinCommandInput(tip):
    r = os.popen("set /p s=" + tip)
    txt = r.read()
    r.close()
    return txt

def on_access_error(func, path, exc_info):
    if not os.access(path, os.W_OK):
        os.chmod(path, stat.S_IWUSR)
        func(path)
    else:
        raise
    
def printF(str, *params):
    str = str % (params)
    print(str)