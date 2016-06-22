import os.path
import shutil


rootDir = "d:/WORK_SPACE/KOF_SRC/svn_kkuu/client/android/fusion2/sdks/"
fromDir = "d:/WORK_SPACE/KOF_SRC/svn_kkuu/client/android/fusion2/JyFusion2SDK/libs_out/"
for dirName in os.listdir(rootDir):
    dirName = dirName + "/libs/"
    dstDir = os.path.join(rootDir, dirName) 
    print "dstDir=" + dstDir
    shutil.copy(fromDir + "alipaysdk.jar", dstDir)
    shutil.copy(fromDir + "alipaysecsdk.jar", dstDir)
    shutil.copy(fromDir + "alipayutdid.jar", dstDir)
    shutil.copy(fromDir + "android-support-v4.jar", dstDir)

os.system("pause")    
