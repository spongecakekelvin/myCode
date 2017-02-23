/****************************************************************************
Copyright (c) 2010-2013 cocos2d-x.org

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
package org.cocos2dx.lib;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.MessageFormat;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.StatFs;
import android.preference.PreferenceManager.OnActivityResultListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.Surface;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;
import box.BoxInstallReceiver;
import box.BoxUtil;

import com.android.zgj.multiChannelPackageTool.MCPTool;
import com.jooyuu.qrlogin4game.ILoginHandler;
import com.jooyuu.qrlogin4game.ILoginResultCallback;
import com.jooyuu.qrlogin4game.QrLoginHandler;
import com.jooyuu.qrlogin4game.bean.LoginResult;
import com.jooyuu.qrlogin4sdk.QrLogin4SDKManager;
import com.jooyuu.qrlogin4sdk.inf.IQrLoginCallBack;
import com.jooyuu.qrlogin4sdk.info.AccountInfo;
import com.jooyuu.qrlogin4sdk.info.QrLoginPostParams;
import com.voice.utils.VoiceCallbackListener;
import com.voice.utils.VoiceHttpRequest;
import com.voice.utils.VoiceManagement;

//import android.R;

public abstract class Cocos2dxActivity extends Activity implements
		Cocos2dxHelperListener {
	// ===========================================================
	// Constants
	// ===========================================================
	private static final int SCAN_CODE = 5208888;
	private final static String TAG = Cocos2dxActivity.class.getSimpleName();
	public static final String UPLOAD_URL = "http://s3.logs.jooyuu.com/androidupload.php";
	// ===========================================================
	// Fields
	// ===========================================================
	private ILoginHandler qrLoginHandler = null;
	private Cocos2dxGLSurfaceView mGLSurfaceView;
	private Cocos2dxHandler mHandler;
	public static Cocos2dxActivity sContext = null;
	// private static BroadcastReceiver connectionReceiver = null;
	private static CCNetBroadcastReceiver connectionReceiver = null;
	private static int luacallback_net = 0;
	// private static int scanQrCodeCallBack = 0;
	private static int luacallback_onpause = 0;
	private static int luacallback_onresume = 0;
	private Cocos2dxVideoHelper mVideoHelper = null;
	
	private static String channelTag = null;
	private static String FS_CHANNEL_FILENAME = "META-INF/jooyuu_fs_channel";

	public static boolean isActivityPaused = false;

	private class LuaCall {
		public String method;
		public String param;

		public LuaCall(String _method, String _param) {
			method = _method;
			param = _param;
		}
	};

	private static Queue<LuaCall> luaCallQueue = new ConcurrentLinkedQueue<LuaCall>();

	// public final static int convert = 1000;
	// public final static String SER_KEY = "org.cocos2dx.lib.message";

	public static Context getContext() {
		return sContext;
	}

	private static void callLuaInGLThread(final String method, final String param){
		// lua 回调
		sContext.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivity.callLuaGlobalFunction(method, param);
			}
		});
	}
	
	/**
	 * 游戏盒子安装成功的逻辑处理
	 */
	private BoxInstallReceiver installReceiver = new BoxInstallReceiver() {
		public void onInstalledBox(Context context) {
			callLuaInGLThread("onGameBoxHanlder", "installed");
		}

		public void onRemovedBox(Context context) {
			callLuaInGLThread("onGameBoxHanlder", "removed");
		}
	};

	protected void onLoadNativeLibraries() {
		try {
			ApplicationInfo ai = getPackageManager().getApplicationInfo(
					getPackageName(), PackageManager.GET_META_DATA);
			Bundle bundle = ai.metaData;
			String libName = bundle.getString("android.app.lib_name");
			System.loadLibrary(libName);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// ===========================================================
	// Constructors
	// ===========================================================

	@Override
	protected void onCreate(final Bundle savedInstanceState) {

		Log.d(TAG, "===================== Cocos2dxActivity  onCreate =====================");
		super.onCreate(savedInstanceState);
		// int currentapiVersion = android.os.Build.VERSION.SDK_INT;
		// if (currentapiVersion >= android.os.Build.VERSION_CODES.FROYO)
		//
		// {
		// getWindow().getDecorView().setSystemUiVisibility(WindowManager.LayoutParams.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
		// }

		// int currentApiVersion = Build.VERSION.SDK_INT;
		// if (currentApiVersion >= 15)
		// {
		// getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
		// //
		// getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE
		// | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
		// }

		onLoadNativeLibraries();

		sContext = this;
		qrLoginHandler = new QrLoginHandler(this, SCAN_CODE);
		this.mHandler = new Cocos2dxHandler(this);

		Cocos2dxHelper.init(this);

		this.init();
		if (mVideoHelper == null) {
			mVideoHelper = new Cocos2dxVideoHelper(this, mFrameLayout);
		}
		connectionReceiver = new CCNetBroadcastReceiver();

		// connectionReceiver = new BroadcastReceiver()
		// {
		// @Override
		// public void onReceive(Context context, Intent intent)
		// {
		// ConnectivityManager connectMgr = (ConnectivityManager)
		// getSystemService(CONNECTIVITY_SERVICE);
		// NetworkInfo mobNetInfo = connectMgr
		// .getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		// NetworkInfo wifiNetInfo = connectMgr
		// .getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		// // if ((mobNetInfo==null)&&(wifiNetInfo==null))
		// // {
		// // if (luacallback_net>0)
		// // {
		// // sContext.runOnGLThread(new Runnable() {
		// // public void run() {
		// // Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// // "no_net");
		// // }
		// // });
		// //
		// // }
		// // }
		// // if (mobNetInfo!=null && !mobNetInfo.isConnected() &&
		// mobNetInfo!=null && !wifiNetInfo.isConnected())
		// // {
		// // if (luacallback_net>0)
		// // {
		// // sContext.runOnGLThread(new Runnable() {
		// // public void run() {
		// // Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// // "no_net");
		// //// Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// // }
		// // });
		// //
		// //// Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "no_net");
		// //// Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// // }
		// //
		// // }
		// // else
		// {
		// if (luacallback_net>0)
		// {
		// if(wifiNetInfo!=null && wifiNetInfo.isConnected())
		// {
		//
		// sContext.runOnGLThread(new Runnable() {
		// public void run() {
		// Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "wifi_net");
		// // Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		// });
		//
		// // Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "wifi_net");
		// // Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		// else if(mobNetInfo!=null && mobNetInfo.isConnected())
		// {
		//
		// sContext.runOnGLThread(new Runnable() {
		// public void run() {
		// Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "mobile_net");
		// // Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		// });
		//
		// // Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "mobile_net");
		// // Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		// else
		// {
		// sContext.runOnGLThread(new Runnable() {
		// public void run() {
		// Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "no_net");
		// // Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		// });
		//
		// // Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
		// "no_net");
		// // Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		//
		// }
		// }
		// }
		// };

		// luacallback_net = 0;
		connectionReceiver.luacallback_net = 0;

		IntentFilter intentFilter = new IntentFilter();
		intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
		registerReceiver(connectionReceiver, intentFilter);

		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
				WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

		// ////////////////////游戏盒子
		BoxUtil.initApkRecevier(sContext, installReceiver);
		
		// voice 语音识别
		initVoiceListener();
	}

	public static void registerLuaCallbackOnPause(final int callbackvalue) {

		luacallback_onpause = callbackvalue;
	}

	public static void registerLuaCallbackOnResume(final int callbackvalue) {

		luacallback_onresume = callbackvalue;
	}

	public static void registerNetMonitor(final int callbackvalue) {
		if (callbackvalue == connectionReceiver.luacallback_net) {
			return;
		}
		if (connectionReceiver.luacallback_net > 0) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(connectionReceiver.luacallback_net);
		}
		connectionReceiver.luacallback_net = callbackvalue;
		// if (callbackvalue==luacallback_net)
		// {
		// return;
		// }
		// if (luacallback_net>0)
		// {
		// Cocos2dxLuaJavaBridge.releaseLuaFunction(luacallback_net);
		// }
		// luacallback_net = callbackvalue;

		// if (connectionReceiver!=null)
		// {
		// return;
		// }
		// connectionReceiver = new BroadcastReceiver()
		// {
		// @Override
		// public void onReceive(Context context, Intent intent)
		// {
		// ConnectivityManager connectMgr = (ConnectivityManager)
		// getSystemService(CONNECTIVITY_SERVICE);
		// NetworkInfo mobNetInfo = connectMgr
		// .getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		// NetworkInfo wifiNetInfo = connectMgr
		// .getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		// if (!mobNetInfo.isConnected() && !wifiNetInfo.isConnected())
		// {
		//
		// } else
		// {
		//
		// }
		// }
		// };
		//
		// luacallback_net = callbackvalue;
		// IntentFilter intentFilter = new IntentFilter();
		// intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
		// registerReceiver(connectionReceiver, intentFilter);
	}

	public static void openUrl(String url) {
		Uri uri = Uri.parse(url);
		Intent it = new Intent(Intent.ACTION_VIEW, uri);
		if (it.resolveActivity(sContext.getPackageManager()) != null) {
			sContext.startActivity(it);
		}

	}

	public static String lua_getExternalStorageDirectory() {
		return Environment.getExternalStorageDirectory().getPath();
	}

	public static String getDiskCacheDir() {
		String cachePath = null;
		// Environment.getExternalStorageDirectory();
		// Environment. getDownloadCacheDirectory () ;
		if (Environment.MEDIA_MOUNTED.equals(Environment
				.getExternalStorageState())
				|| !Environment.isExternalStorageRemovable()) {
			// cachePath = sContext.getExternalCacheDir().getPath();
			cachePath = Environment.getExternalStorageDirectory().toString();
		} else {
			// cachePath = sContext.getCacheDir().getPath();
			File dir = sContext.getDir("apks3", Context.MODE_PRIVATE
					| Context.MODE_WORLD_READABLE
					| Context.MODE_WORLD_WRITEABLE);
			cachePath = dir.toString();
		}
		return cachePath;
	}

	public static void changeFileMod(String filepath) {
		String[] command = { "chmod", "777", filepath };
		ProcessBuilder builder = new ProcessBuilder(command);
		try {
			builder.start();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static void exitGameNow() {
		// 游戏即将退出的时候，完成sdk推出的回调
//		Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
//				"javaCallLuaGlobalFun", "exitGame" + "#" + 0 + "#()");
		sContext.finish();
		System.exit(0);
	}

	public static void arpgexit(String tipTemp, String contentTemp,
			String leftstrTemp, String rightstrTemp) {
		final String tip = tipTemp;
		final String content = contentTemp;
		final String leftstr = leftstrTemp;
		final String rightstr = rightstrTemp;
		sContext.runOnUiThread(new Runnable() {

			public void run() {
				AlertDialog.Builder builder = new AlertDialog.Builder(sContext);
				builder.setTitle(tip);
				builder.setMessage(content);
				builder.setIcon(android.R.drawable.ic_dialog_info);
				builder.setPositiveButton(leftstr,
						new DialogInterface.OnClickListener() {

							public void onClick(DialogInterface dialog,
									int which) {
								exitGameNow();
							}
						});
				builder.setNegativeButton(rightstr,
						new DialogInterface.OnClickListener() {

							public void onClick(DialogInterface dialog,
									int which) {
								dialog.dismiss();
							}
						}).show();
			}
		});
	}

	public static void selfsetRequestedOrientation(int screenType) {
		// setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
		sContext.setRequestedOrientation(screenType);
	}

	public static int getDisplayRotation() {

		int rotation = sContext.getWindowManager().getDefaultDisplay()
				.getRotation();
		switch (rotation) {
		case Surface.ROTATION_0:
			return 0;
		case Surface.ROTATION_90:
			return 90;
		case Surface.ROTATION_180:
			return 180;
		case Surface.ROTATION_270:
			return 270;
		}
		return 0;
	}

	public static void clearApkFiles() {
		String path = Environment.getExternalStorageDirectory().toString()
				+ "/s3arpg.apk";
		final File file = new File(path);
		if (file.exists()) {
			file.delete();
		}

		File dir = sContext.getDir("apks3", Context.MODE_PRIVATE
				| Context.MODE_WORLD_READABLE | Context.MODE_WORLD_WRITEABLE);

		path = dir.toString() + "/s3arpg.apk";
		final File file1 = new File(path);
		if (file1.exists()) {
			file1.delete();
		}
	}
	
	public static String getFileMD5(String filepath) {
		final File file = new File(filepath);
	   if (!file.exists()) {
	      return "";
	    }
	    MessageDigest digest = null;
	    FileInputStream in=null;
	    byte buffer[] = new byte[10240];
	    int len;
	    try {
	      digest = MessageDigest.getInstance("MD5");
	      in = new FileInputStream(file);
	      while ((len = in.read(buffer, 0, 10240)) != -1) {
	        digest.update(buffer, 0, len);
	      }
	      in.close();
	    } catch (Exception e) {
	      e.printStackTrace();
	      return "";
	    }
	    BigInteger bigInt = new BigInteger(1, digest.digest());
	    return bigInt.toString(16);
	  }
	  
	  /**
	   * 获取文件夹中文件的MD5值
	   * @param file
	   * @param listChild ;true递归子目录中的文件
	   * @return
	   */
	  public static Map<String, String> getDirMD5(File file,boolean listChild) {
	    if(!file.isDirectory()){
	      return null;
	    }
	    //<filepath,md5>
	    Map<String, String> map=new HashMap<String, String>();
	    String md5;
	    File files[]=file.listFiles();
	    for(int i=0;i<files.length;i++){
	      File f=files[i];
	      if(f.isDirectory()&&listChild){
	        map.putAll(getDirMD5(f, listChild));
	      } else {
	        md5=getFileMD5(f.getPath());
	        if(md5!=null){
	          map.put(f.getPath(), md5);
	        }
	      }
	    }
	    return map;
	  }

	



	public static void openApkFile(String fileName) {
		// TODO Auto-generated method stub
		final File file = new File(fileName);
		if (file.exists()) {
			Intent intent = new Intent();
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.setAction(android.content.Intent.ACTION_VIEW);
			intent.setDataAndType(Uri.fromFile(file),
					"application/vnd.android.package-archive");
			sContext.startActivity(intent);

			// Intent i = new Intent(Intent.ACTION_VIEW);
			// i.setDataAndType(Uri.parse("file://" + file.toString()),
			// //"application/vnd.android.package-archive");
			// sContext.startActivity(i);
		}
	}

	public static boolean isNetConnected() {
		if (sContext != null) {
			ConnectivityManager mConnectivityManager = (ConnectivityManager) sContext
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo mNetworkInfo = mConnectivityManager
					.getActiveNetworkInfo();
			if (mNetworkInfo != null) {
				return mNetworkInfo.isAvailable();
			}
		}
		return false;
	}
	
	// 修复部分机型wifi下加载资源bug
	public static boolean isWifiConnected() {
		if (sContext != null) {
			ConnectivityManager mConnectivityManager = (ConnectivityManager) sContext
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			 NetworkInfo activeNetInfo = mConnectivityManager.getActiveNetworkInfo();
			 if (activeNetInfo != null && activeNetInfo.getType() == ConnectivityManager.TYPE_WIFI){
				return true; 
			 }
		}
		return false;
	}
	
	public static boolean isWifiConnected_deprecated() {
		if (sContext != null) {
			ConnectivityManager mConnectivityManager = (ConnectivityManager) sContext
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo mWiFiNetworkInfo = mConnectivityManager
					.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
			if (mWiFiNetworkInfo != null) {
				return mWiFiNetworkInfo.isAvailable();
			}
		}
		return false;
	}

	public static boolean isMobileConnected() {
		if (sContext != null) {
			ConnectivityManager mConnectivityManager = (ConnectivityManager) sContext
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo mMobileNetworkInfo = mConnectivityManager
					.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
			if (mMobileNetworkInfo != null) {
				return mMobileNetworkInfo.isAvailable();
			}
		}
		return false;
	}

	public static int getMobileSubType() {
		if (sContext != null) {
			ConnectivityManager mConnectivityManager = (ConnectivityManager) sContext
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo mMobileNetworkInfo = mConnectivityManager
					.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
			if (mMobileNetworkInfo != null) {
				return mMobileNetworkInfo.getSubtype();
			}
		}
		return -1;
	}

	public static int getConnectedType() {
		if (sContext != null) {
			ConnectivityManager mConnectivityManager = (ConnectivityManager) sContext
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo mNetworkInfo = mConnectivityManager
					.getActiveNetworkInfo();
			if (mNetworkInfo != null && mNetworkInfo.isAvailable()) {
				return mNetworkInfo.getType();
			}
		}
		return -1;
	}

	public static boolean ExistSDCard() {
		if (android.os.Environment.getExternalStorageState().equals(
				android.os.Environment.MEDIA_MOUNTED)) {
			return true;
		} else
			return false;
	}

	public static int getSDFreeSize() {
		// 取锟斤拷SD锟斤拷锟侥硷拷路锟斤拷
		File path = Environment.getExternalStorageDirectory();
		StatFs sf = new StatFs(path.getPath());
		long blockSize = sf.getBlockSize();
		long freeBlocks = sf.getAvailableBlocks();
		// return freeBlocks * blockSize;
		// return (freeBlocks * blockSize)/1024;
		return (int) (((freeBlocks * blockSize) / 1024) / 1024);
	}

	public static int getSDAllSize() {
		// 取锟斤拷SD锟斤拷锟侥硷拷路锟斤拷
		File path = Environment.getExternalStorageDirectory();
		StatFs sf = new StatFs(path.getPath());
		long blockSize = sf.getBlockSize();
		long allBlocks = sf.getBlockCount();
		// return allBlocks * blockSize;
		// return (allBlocks * blockSize)/1024;
		return (int) (((allBlocks * blockSize) / 1024) / 1024);
	}

	public static int getExternalStorageAvailableSize() {
		if (Environment.getExternalStorageState().equals(
				Environment.MEDIA_MOUNTED)) {
			String path = Environment.getExternalStorageDirectory().getPath();
			StatFs stat = new StatFs(path);
			long blockSize = stat.getBlockSize();
			// long totalBlocks = stat.getBlockCount();
			long availableBlocks = stat.getAvailableBlocks();
			// long totalSize = blockSize * totalBlocks;

			long availableSize = blockSize * availableBlocks;

			return (int) ((availableSize / 1024) / 1024);

		}

		else {
			return -1;
		}
	}
	
	/**
	 * 获取自定义用户文件的保存路径
	 * @return
	 */
    public static String getUserFileDirectory(){
    	String path = Environment.getExternalStorageDirectory().getPath();
	    ApplicationInfo appinfo = sContext.getApplicationInfo();
    	path = path + File.separator + appinfo.packageName + File.separator;
    	return path;
    }

	public static int getInternalStorageAvailableSize() {
		File path = Environment.getDataDirectory();

		StatFs stat = new StatFs(path.getPath());

		long blockSize = stat.getBlockSize();

		// long totalBlocks = stat.getBlockCount();

		long availableBlocks = stat.getAvailableBlocks();

		// long totalSize1 = blockSize1 * totalBlocks1;

		long availableSize = blockSize * availableBlocks;
		return (int) ((availableSize / 1024) / 1024);

	}

	// ===========================================================
	// Getter & Setter
	// ===========================================================

	// ===========================================================
	// Methods for/from SuperClass/Interfaces
	// ===========================================================

	@Override
	protected void onResume() {

		// sContext.runOnGLThread(new Runnable()
		// {
		// @Override
		// public void run()
		// {
		// Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
		// "androidOnResume", "");
		// }
		// });
		Log.d(TAG, "  onResume ");
		if (luacallback_onresume > 0) {
			sContext.runOnGLThread(new Runnable() {
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
							luacallback_onresume, "");
				}
			});
		}

		super.onResume();
		Cocos2dxHelper.onResume();
		this.mGLSurfaceView.onResume();

		isActivityPaused = false;
		doLuaCalls();
	}

	@Override
	protected void onPause() {
		isActivityPaused = true;
		// sContext.runOnGLThread(new Runnable()
		// {
		// @Override
		// public void run()
		// {
		// Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
		// "androidOnPause", "");
		// }
		// });
		Log.d(TAG, " onPause ");
		if (luacallback_onpause > 0) {
			sContext.runOnGLThread(new Runnable() {
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
							luacallback_onpause, "");
				}
			});
		}

		super.onPause();

		Cocos2dxHelper.onPause();
		this.mGLSurfaceView.onPause();
	}
	
	public static boolean doLuaCalls(){
		if (!luaCallQueue.isEmpty()) {
				new Handler().postDelayed(new Runnable(){      
				    public void run() {      
				    	Log.d(TAG, "~~~~ delay call");
				    	sContext.runOnGLThread(new Runnable() {
							public void run() {
								// 执行队列
								for (LuaCall q : luaCallQueue) {
									Log.d(TAG, "执行  lua " + q.method + "," + q.param);
									Cocos2dxActivity.callLuaGlobalFunction(q.method, q.param);
								}
								luaCallQueue.clear();
							}
						});
				    }      
				 }, 400);
			return true;
		}
		return false;
	}

	public static void callLuaGlobalFunction(String method, String param) {
		if (isActivityPaused) {
			// 加入列表
			Log.d(TAG, "加入列表" + method + "," + param);
			luaCallQueue.add(sContext.new LuaCall(method, param));

		} else {
			Cocos2dxLuaJavaBridge
					.callLuaGlobalFunctionWithString(method, param);
		}
	}

	@Override
	protected void onDestroy() {
		if (connectionReceiver != null) {
			unregisterReceiver(connectionReceiver);
		}
		connectionReceiver = null;

		sContext.unregisterReceiver(installReceiver);

		super.onDestroy();
	}

	@Override
	public void showDialog(final String pTitle, final String pMessage) {
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_DIALOG;
		msg.obj = new Cocos2dxHandler.DialogMessage(pTitle, pMessage);
		this.mHandler.sendMessage(msg);
	}

	@Override
	public void showEditTextDialog(final String pTitle, final String pContent,
			final int pInputMode, final int pInputFlag, final int pReturnType,
			final int pMaxLength) {
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_EDITBOX_DIALOG;
		msg.obj = new Cocos2dxHandler.EditBoxMessage(pTitle, pContent,
				pInputMode, pInputFlag, pReturnType, pMaxLength);
		this.mHandler.sendMessage(msg);
	}

	@Override
	public void runOnGLThread(final Runnable pRunnable) {
		this.mGLSurfaceView.queueEvent(pRunnable);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		String result = "";
		if (requestCode == SCAN_CODE) {

			if (resultCode == RESULT_OK) {
				result = data.getStringExtra("scan_result");
				qrLoginHandler.onScanResult(result);
			} else if (resultCode == RESULT_CANCELED) {
				result = "没有扫描出结果";
			}
			setScanTxtResult(result);
		} else {

			for (OnActivityResultListener listener : Cocos2dxHelper
					.getOnActivityResultListeners()) {
				listener.onActivityResult(requestCode, resultCode, data);
			}
		}

		super.onActivityResult(requestCode, resultCode, data);
	}

	protected FrameLayout mFrameLayout = null;

	// ===========================================================
	// Methods
	// ===========================================================
	public void init() {

		// FrameLayout
		ViewGroup.LayoutParams framelayout_params = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.MATCH_PARENT,
				ViewGroup.LayoutParams.MATCH_PARENT);
		mFrameLayout = new FrameLayout(this);
		mFrameLayout.setLayoutParams(framelayout_params);

		// Cocos2dxEditText layout
		ViewGroup.LayoutParams edittext_layout_params = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.MATCH_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);
		Cocos2dxEditText edittext = new Cocos2dxEditText(this);
		edittext.setLayoutParams(edittext_layout_params);

		// ...add to FrameLayout
		mFrameLayout.addView(edittext);

		// Cocos2dxGLSurfaceView
		this.mGLSurfaceView = this.onCreateView();

		// ...add to FrameLayout
		mFrameLayout.addView(this.mGLSurfaceView);

		// Switch to supported OpenGL (ARGB888) mode on emulator
		if (isAndroidEmulator())
			this.mGLSurfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0);

		this.mGLSurfaceView.setCocos2dxRenderer(new Cocos2dxRenderer());
		this.mGLSurfaceView.setCocos2dxEditText(edittext);

		// Set framelayout as the content view

		// int currentApiVersion = Build.VERSION.SDK_INT;
		// if (currentApiVersion >= 15)
		// {
		//
		// main = getLayoutInflater().from(this).inflate(R.layout.main, null);
		// main.setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
		// main.setOnClickListener(this);
		// setContentView(main);
		//
		// mFrameLayout.setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
		// mFrameLayout.setOnClickListener(this);
		// }

		setContentView(mFrameLayout);

		TextView texttmp = new TextView(this);
		texttmp.setText("");
		mFrameLayout.addView(texttmp);
	}

	// public void onClick(View v) {
	// int i = main.getSystemUiVisibility();
	// if (i == View.SYSTEM_UI_FLAG_HIDE_NAVIGATION) {
	// main.setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
	// } else if (i == View.SYSTEM_UI_FLAG_VISIBLE){
	// main.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);
	// } else if (i == View.SYSTEM_UI_FLAG_LOW_PROFILE) {
	// main.setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
	// }
	// }
	// }

	public static void copy(String content) {

		// Log.d(TAG, "***************************="
		// + android.os.Build.VERSION.SDK_INT);
		//
		// if (android.os.Build.VERSION.SDK_INT > 11)
		// {
		// Log.d(TAG, "***************************1");
		// try
		// {
		// android.content.ClipboardManager cmb =
		// (android.content.ClipboardManager) sContext
		// .getSystemService(Context.CLIPBOARD_SERVICE);
		//
		// Log.d(TAG, "***************************2");
		//
		// android.content.ClipData clip = android.content.ClipData
		// .newPlainText("simple text", content.trim());
		//
		// cmb.setPrimaryClip(clip);
		// } catch (Exception e)
		// {
		// e.printStackTrace();
		// }
		//
		//
		// } else
		// {
		//
		//
		// try
		// {
		// android.text.ClipboardManager cmb = (android.text.ClipboardManager)
		// sContext
		// .getSystemService(Context.CLIPBOARD_SERVICE);
		// cmb.setText(content.trim());
		// } catch (Exception e)
		// {
		// e.printStackTrace();
		// }
		//
		// }

	}

	public static String paste() {
		// if (android.os.Build.VERSION.SDK_INT > 11)
		// {
		//
		// try
		// {
		// android.content.ClipboardManager mClipboard =
		// (android.content.ClipboardManager) sContext
		// .getSystemService(Context.CLIPBOARD_SERVICE);
		//
		// String resultString = "";
		//
		// if (!mClipboard.hasPrimaryClip())
		// {
		// return "";
		// } else
		// {
		// android.content.ClipData clipData = mClipboard.getPrimaryClip();
		// int count = clipData.getItemCount();
		//
		// for (int i = 0; i < count; ++i)
		// {
		//
		// android.content.ClipData.Item item = clipData.getItemAt(i);
		// CharSequence str = item.coerceToText(sContext);
		//
		// resultString += str;
		// }
		//
		// }
		// return resultString;
		//
		// } catch (Exception e)
		// {
		// e.printStackTrace();
		// }
		//
		//
		//
		// } else
		// {
		//
		// try
		// {
		// android.text.ClipboardManager cmb = (android.text.ClipboardManager)
		// sContext
		// .getSystemService(Context.CLIPBOARD_SERVICE);
		// return cmb.getText().toString().trim();
		// } catch (Exception e)
		// {
		// e.printStackTrace();
		// }
		//
		//
		//
		// }

		return "";

	}

	public Cocos2dxGLSurfaceView onCreateView() {
		// return new Cocos2dxGLSurfaceView(this);
		Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
		// TestCpp should create stencil buffer
		glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);

		return glSurfaceView;
	}

	public static String getDeviceInf() {
		StringBuilder sb = new StringBuilder();
		sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
		sb.append("BOARD ").append(android.os.Build.BOARD).append("\n");
		sb.append("BOOTLOADER ").append(android.os.Build.BOOTLOADER)
				.append("\n");
		sb.append("BRAND ").append(android.os.Build.BRAND).append("\n");
		sb.append("CPU_ABI ").append(android.os.Build.CPU_ABI).append("\n");
		sb.append("CPU_ABI2 ").append(android.os.Build.CPU_ABI2).append("\n");
		sb.append("DEVICE ").append(android.os.Build.DEVICE).append("\n");
		sb.append("DISPLAY ").append(android.os.Build.DISPLAY).append("\n");
		sb.append("FINGERPRINT ").append(android.os.Build.FINGERPRINT)
				.append("\n");
		sb.append("HARDWARE ").append(android.os.Build.HARDWARE).append("\n");
		sb.append("HOST ").append(android.os.Build.HOST).append("\n");
		sb.append("ID ").append(android.os.Build.ID).append("\n");
		sb.append("MANUFACTURER ").append(android.os.Build.MANUFACTURER)
				.append("\n");
		sb.append("MODEL ").append(android.os.Build.MODEL).append("\n");
		sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
		sb.append("RADIO ").append(android.os.Build.RADIO).append("\n");
		sb.append("SERIAL ").append(android.os.Build.SERIAL).append("\n");
		sb.append("TAGS ").append(android.os.Build.TAGS).append("\n");
		sb.append("TIME ").append(android.os.Build.TIME).append("\n");
		sb.append("TYPE ").append(android.os.Build.TYPE).append("\n");
		sb.append("USER ").append(android.os.Build.USER).append("\n");

		String result = sb.toString() + "#####";

		result = result + android.os.Build.MODEL + ","
				+ android.os.Build.VERSION.SDK_INT + ","
				+ android.os.Build.VERSION.RELEASE;

		return result;
	}

	private final static boolean isAndroidEmulator() {
		String model = Build.MODEL;
		Log.d(TAG, "model=" + model);
		String product = Build.PRODUCT;
		Log.d(TAG, "product=" + product);
		boolean isEmulator = false;
		if (product != null) {
			isEmulator = product.equals("sdk") || product.contains("_sdk")
					|| product.contains("sdk_");
		}
		Log.d(TAG, "isEmulator=" + isEmulator);
		return isEmulator;
	}

	// //Serializeable浼犻�瀵硅薄鐨勬柟娉� //
	// public void SerializeMethod(NotificationMessage message) {
	//
	// Intent intent = new Intent();
	//
	// intent.setClass(sContext, CCNotifitionService.class);
	//
	// Bundle mBundle = new Bundle();
	//
	// mBundle.putSerializable(SER_KEY, message);
	//
	// intent.putExtras(mBundle);
	//
	// sContext.startService(intent);
	//
	// System.out.println("Push notify message.");
	//
	// }
	//
	//
	//
	// public static void pushMessage(String message,long mark,int repeats) {
	//
	//
	//
	// System.out.println("pushMessage"+mark);
	//
	//
	//
	// NotificationMessage nmObj = new NotificationMessage();
	//
	// nmObj.setMessage(message);
	//
	// nmObj.setMark(mark * convert);
	//
	// nmObj.setId(repeats);
	//
	// sContext.SerializeMethod(nmObj);
	//
	// }

	public static void rebootApp() {
		// Intent i = sContext
		// .getBaseContext()
		// .getPackageManager()
		// .getLaunchIntentForPackage(
		// sContext.getBaseContext().getPackageName());
		// i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		// sContext.startActivity(i);

		// System.exit(0);
		// Intent intent = new Intent(this, MainActivity.class);
		// intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP |
		// Intent.FLAG_ACTIVITY_NEW_TASK);
		// sContext.startActivity(intent);

		sContext.runOnUiThread(new Runnable() {

			public void run() {
				Intent intent = new Intent(sContext, sContext.getClass());
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				sContext.startActivity(intent);
				android.os.Process.killProcess(android.os.Process.myPid());
			}
		});
	}

	public static void addNoticfy(String title, String content, int delalt,
			int key, int repeatTime) {
		JSONObject j = new JSONObject();
		try {
			j.put("ticker", content);
			j.put("title", title);
			j.put("text", content);
			if (repeatTime <= 0) {
				j.put("tag", "once");
			} else {
				j.put("intervalAtMillis", repeatTime);
			}
			j.put("triggerOffset", delalt);
			j.put("id", key);
			// j.put("packageName",
			// "org.cocos2dx.lib.Cocos2dxActivity");//鍖呭悕娉ㄦ剰濉�
			// j.put("packageName", "org.cocos2dx.lua.AppActivity");// 鍖呭悕娉ㄦ剰濉�
			// Cocos2dxAlarmManager.alarmNotify(sContext, j.toString());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static void onNativeCrashed() {

		Log.i("wuchao", "asdasdasdasdasdasddasdas");

		new RuntimeException(
				"crashed here (native trace should follow after the Java trace)")
				.printStackTrace();

		// throw new
		// RuntimeException("crashed here (native trace should follow after the Java trace)");

		getContext().startActivity(
				new Intent(getContext(), Cocos2dxCrashHandler.class));

	}

	static String readAllOf(InputStream s) throws IOException

	{

		BufferedReader bufferedReader = new BufferedReader(
				new InputStreamReader(s), 8096);

		String line;

		StringBuilder log = new StringBuilder();

		while ((line = bufferedReader.readLine()) != null) {

			log.append(line);

			log.append("\n");

		}

		return log.toString();

	}

	static boolean tryEmailAuthor(Context c, boolean isCrash, String body)

	{

		String addr = c.getString(R.string.author_email);

		Intent i = new Intent(Intent.ACTION_SEND);

		String modVer = "";

		// try {
		//
		// Process p = Runtime.getRuntime().exec(new
		// String[]{"getprop","ro.modversion"});
		//
		// modVer = readAllOf(p.getInputStream()).trim();
		//
		// } catch (Exception e) {}

		if (modVer.length() == 0)
			modVer = "original";

		// second empty address because of
		// http://code.google.com/p/k9mail/issues/detail?id=589

		i.putExtra(Intent.EXTRA_EMAIL, new String[] { addr, "" });

		i.putExtra(Intent.EXTRA_SUBJECT, MessageFormat.format(c.getString(

		isCrash ? R.string.crash_subject : R.string.email_subject),

		getVersion(c), Build.MODEL, modVer, Build.FINGERPRINT));

		i.setType("message/rfc822");

		i.putExtra(Intent.EXTRA_TEXT, body != null ? body : "");

		try {

			c.startActivity(i);

			return true;

		} catch (ActivityNotFoundException e) {

			try {

				// Get the OS to present a nicely formatted, translated error

				c.startActivity(Intent.createChooser(i, null));

			} catch (Exception e2) {

				e2.printStackTrace();

				Toast.makeText(c, e2.toString(), Toast.LENGTH_LONG).show();

			}

			return false;

		}

	}

	static String getVersion(Context c) {

		try {

			return c.getPackageManager().getPackageInfo(c.getPackageName(), 0).versionName;

		} catch (Exception e) {
			return c.getString(R.string.unknown_version);
		}

	}

	// private static ArrayList<String> getDevMountList() {
	// String[] toSearch = FileUtils.readFile("/etc/vold.fstab").split(" ");
	// ArrayList<String> out = new ArrayList<String>();
	// for (int i = 0; i < toSearch.length; i++) {
	// if (toSearch[i].contains("dev_mount")) {
	// if (new File(toSearch[i + 2]).exists()) {
	// out.add(toSearch[i + 2]);
	// }
	// }
	// }
	// return out;
	// }
	//
	// /**
	// * 获取扩展SD卡存储目录
	// *
	// * 如果有外接的SD卡，并且已挂载，则返回这个外置SD卡目录
	// * 否则：返回内置SD卡目录
	// *
	// * @return
	// */
	// public static String getExternalSdCardPath() {
	//
	// if (Environment.MEDIA_MOUNTED.equals(Environment
	// .getExternalStorageState())
	// || !Environment.isExternalStorageRemovable())
	// {
	// File sdCardFile = new
	// File(Environment.getExternalStorageDirectory().getAbsolutePath());
	// return sdCardFile.getAbsolutePath();
	// }
	//
	// String path = null;
	//
	// File sdCardFile = null;
	//
	// ArrayList<String> devMountList = getDevMountList();
	//
	// for (String devMount : devMountList) {
	// File file = new File(devMount);
	//
	// if (file.isDirectory() && file.canWrite()) {
	// path = file.getAbsolutePath();
	//
	// String timeStamp = new SimpleDateFormat("ddMMyyyy_HHmmss").format(new
	// Date());
	// File testWritable = new File(path, "test_" + timeStamp);
	//
	// if (testWritable.mkdirs()) {
	// testWritable.delete();
	// } else {
	// path = null;
	// }
	// }
	// }
	//
	// if (path != null) {
	// sdCardFile = new File(path);
	// return sdCardFile.getAbsolutePath();
	// }
	//
	// return null;
	// }

	static Handler fileHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				// Toast.makeText(getApplicationContext(), "文件或文件夹不存在",
				// Toast.LENGTH_LONG).show();
				callLuaInGLThread("deleteFileDirOnAndroid", "文件或文件夹不存在");
				break;
			case 1:
				// Toast.makeText(getApplicationContext(), "删除成功！",
				// Toast.LENGTH_LONG).show();
				callLuaInGLThread("deleteFileDirOnAndroid", "删除成功");
				break;
			default:
				break;
			}
		};
	};

	public static void restartGame_common() {
		sContext.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivity.sContext.restart_common();
			}
		});

	}

	public void restart_common() {
		Intent intent = new Intent(Cocos2dxActivity.sContext,
				Cocos2dxActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		Cocos2dxActivity.sContext.startActivity(intent);
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	/**
	 * 递归删除文件和文件夹
	 * 
	 * @param file
	 *            要删除的根目录
	 */

	public static void DeleteFile(File file) {
		if (file.exists() == false) {
			fileHandler.sendEmptyMessage(0);
			return;
		} else {
			if (file.isFile()) {
				file.delete();
				return;
			}
			if (file.isDirectory()) {
				File[] childFile = file.listFiles();
				if (childFile == null || childFile.length == 0) {
					// file.delete();
					return;
				}
				for (File f : childFile) {
					DeleteFile(f);
				}
				// file.delete();
			}
		}
	}

	public static void DeleteDir(String path) {
		File file = new File(path);
		DeleteFile(file);
	}

	public static String getChannelID(String passwd) {
		String channel_tag = MCPTool.getChannelId(sContext, passwd, "default");
		if (channel_tag == "" || channel_tag == "default"){
			Log.e(TAG,  "(1) get channel tag = " + channel_tag);
			channel_tag =  getChannelIDByMetaInfo();
		}
		return channel_tag;
	}
	
	/**
	 * 读取META-INFO中的渠道号
	 */
	public static String getChannelIDByMetaInfo() {
		if (channelTag != null) {
			return channelTag;
		}

		ZipFile zipfile = null;
		try {
			ApplicationInfo appinfo = sContext.getApplicationInfo();
			String sourceDir = appinfo.sourceDir;

			zipfile = new ZipFile(sourceDir);
			Enumeration<?> entries = zipfile.entries();
			while (entries.hasMoreElements()) {
				ZipEntry entry = ((ZipEntry) entries.nextElement());
				String entryName = entry.getName();
				if (FS_CHANNEL_FILENAME.equals(entryName)) {
					channelTag = readZipFileContent(zipfile, entry);
					return channelTag;
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (zipfile != null) {
				try {
					zipfile.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return "";
	}
	
	private static String readZipFileContent(ZipFile zipfile, ZipEntry entry) {
		long size = entry.getSize();
		if (size > 0) {
			try {
				BufferedReader br = new BufferedReader(new InputStreamReader(zipfile.getInputStream(entry)));
				StringBuilder sb = new StringBuilder();
				String line;
				while ((line = br.readLine()) != null) {
					sb.append(line);
				}
				br.close();
				return sb.toString();
			} catch (Exception e) {
				e.printStackTrace();
				return "";
			}
		}
		return "";
	}

	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
	public static String getUniID() {
		String m_szLongID = getDeviceInf();
		// String m_szLongID = m_szImei + m_szDevIDShort
		// + m_szAndroidID+ m_szWLANMAC + m_szBTMAC;
		// compute md5
		MessageDigest m = null;
		try {
			m = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		m.update(m_szLongID.getBytes(), 0, m_szLongID.length());
		// get md5 bytes
		byte p_md5Data[] = m.digest();
		// create a hex string
		String m_szUniqueID = new String();
		for (int i = 0; i < p_md5Data.length; i++) {
			int b = (0xFF & p_md5Data[i]);
			// if it is a single digit, make sure it have 0 in front (proper
			// padding)
			if (b <= 0xF)
				m_szUniqueID += "0";
			// add number to string
			m_szUniqueID += Integer.toHexString(b);
		} // hex string to uppercase
		m_szUniqueID = m_szUniqueID.toUpperCase();
		return m_szUniqueID;
	}

	// 安装游戏盒子
	public static void installGameBox() {
		sContext.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Log.i(TAG, "安装游戏盒子!!!");
				BoxUtil.installGameBox(sContext);
			}
		});

	}

	/**
	 * 是否已安装
	 * 
	 * @param 包名
	 */
	public static boolean isInstalled(String packageName) {
		if (packageName == null) {
			return false;
		}

		List<PackageInfo> packages = sContext.getPackageManager()
				.getInstalledPackages(0);

		for (int i = 0; i < packages.size(); i++) {
			PackageInfo packageInfo = packages.get(i);
			// Log.e("isInstalled pn", packageInfo.packageName);
			// Log.e("isInstalled app name",
			// packageInfo.applicationInfo.loadLabel(getPackageManager()).toString());
			if (packageInfo.packageName.equals(packageName)) {
				return true;
			}
		}
		return false;
	}

	public static String getPhoneIMEI() {
		try {
			return getPhoneIMEI(sContext);
		} catch (Exception e) {
			return "";
		}
	}

	/**
	 * 获取SIM卡IEMI
	 * 
	 * @param context
	 * @return
	 */
	private static String getPhoneIMEI(Context context) {
		String phoneIMEI = ((TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();
		if (phoneIMEI==null) {
	      return "";
	    }
		return phoneIMEI;
	}
	

	public static void scanQrCodeDemo() {
		int gameID = 10;
		String accountName = "testAccount";
		String platformName = "xiaomi";
		int serverID = 1;
		String ext = "ext";
		String loginApiUrl = "http://qrlogin4game.kkuu.com/api/loginWebGame";
		String signKey = "QrLogin.UfY5syFezujaK8T9";
		String loginForwardUrl = "http://www.baidu.com";

		scanQrCode(accountName, platformName, loginForwardUrl, ext,
				loginApiUrl, signKey, gameID, serverID, 0);
	}

	/**
	 * 这个可以作为GameUtil给Cocos2dx调用的静态函数
	 * 
	 * @param gameID
	 * @param accountName
	 * @param platformName
	 * @param serverID
	 * @param loginForwardUrl
	 * @param ext
	 * @param loginApiUrl
	 * @param signKey
	 */
	public static void scanQrCode(final String accountName,
			final String platformName, final String loginForwardUrl,
			final String ext, final String loginApiUrl, final String signKey,
			final int gameID, final int serverID, final int callback) {

		ILoginHandler handler = sContext.getQrLoginHandler();

		handler.scanQrCode(gameID, accountName, platformName, serverID,
				loginForwardUrl, ext, loginApiUrl, signKey,
				new ILoginResultCallback() {

					@Override
					public void handleLoginResult(LoginResult errResult) {
						// TODO:项目要自己修改
						// 这里应该加上回调Cocos2dx或者U3D的代码
						// String msg = "errCode=" + errResult.errCode + ";msg="
						// + errResult.msg;
						if (callback > 0) {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									callback, "" + errResult.errCode);
						}

						// Toast.makeText(sContext, msg.toString(),
						// Toast.LENGTH_SHORT).show();
					}

				});
	}

	public ILoginHandler getQrLoginHandler() {
		return this.qrLoginHandler;
	}

	private void setScanTxtResult(String result) {

	}

	/**
	 * 弹出扫码登录选择框
	 * 
	 * @param context
	 */

	public static void startScanQRLogin() {
		scanQRLogin(sContext);
	}

	private static void scanQRLogin(final Context context) {
		String apiUrl = "http://qrlogin4sdk.kkuu.com/api/getAccountByQrcode";
		String apiKey = "QrLogin4SDK.3xVrnCWMmBwh2g1hW"; // 登录key值

		QrLoginPostParams qrLoginPostParams = new QrLoginPostParams(apiUrl,
				apiKey);
		QrLogin4SDKManager.getInstance().qrLogin(context, qrLoginPostParams,
				true, new IQrLoginCallBack() {

					@Override
					public void qrLoginResult(int errCode, String msg,
							final AccountInfo account) {
						Log.e("jooyuu", "wuzesen,errCode=" + errCode);
						Log.e("jooyuu", "wuzesen,msg=" + msg);

						if (errCode == 0) {
							Toast.makeText(context, "登录成功！", Toast.LENGTH_SHORT)
									.show();
							callLuaInGLThread("onQRLoginResult",
													accountToString(account));
						} else {
							Toast.makeText(context, "登录失败！" + msg,
									Toast.LENGTH_LONG).show();
						}

					}

				});
	}

	private static String accountToString(final AccountInfo account) {
		int game_id = account.game_id;
		String platform_name = account.platform_name != null ? account.platform_name
				: "";
		String account_name = account.account_name != null ? account.account_name
				: "";
		int agent_id = account.agent_id;
		int server_id = account.server_id;
		String role_id = account.role_id != null ? account.role_id : "";
		String ext = account.token != null ? account.ext : "";
		String token = account.token != null ? account.token : "";
		int token_expire_time = account.token_expire_time;

		Log.e("jooyuu", "game_id=" + game_id);
		Log.e("jooyuu", "platform_name=" + platform_name);
		Log.e("jooyuu", "account_name=" + account_name);
		Log.e("jooyuu", "agent_id=" + agent_id);
		Log.e("jooyuu", "server_id=" + server_id);
		Log.e("jooyuu", "role_id=" + role_id);
		Log.e("jooyuu", "ext=" + ext);
		Log.e("jooyuu", "token=" + token);
		Log.e("jooyuu", "token_expire_time=" + token_expire_time);

		StringBuilder sb = new StringBuilder();
		sb.append(game_id + "|");
		sb.append(platform_name + "|");
		sb.append(account_name + "|");
		sb.append(agent_id + "|");
		sb.append(server_id + "|");
		sb.append(role_id + "|");
		sb.append(ext + "|");
		sb.append(token + "|");
		sb.append(token_expire_time);

		return sb.toString();
	}

	/**
	 * 关闭扫码登录框
	 */
	public static void qrLogout() {
		QrLogin4SDKManager.getInstance().qrLogout();
	}
	

	/**
	 * 语音听写
	 * 
	 * @author YuZhenjian
	 */
	private void initVoiceListener() {
		// 语音识别
		VoiceManagement.getInstance().setActivity(sContext);

		// 监听回调
		VoiceManagement.getInstance().setVoiceCallBackListener(new VoiceCallbackListener() {
			public void onBeginOfSpeech() {
				callLuaInGLThread("onVoiceBeginOfSpeech", "");
			}

			public void onEndOfSpeech() {
				callLuaInGLThread("onVoiceEndOfSpeech", "");
			}

			public void onResult(final String resultStr) {
				// Log.i("appActivity", "onResult~~~~~~~~~~~~~~~~~~");
				callLuaInGLThread("onVoiceResult", resultStr);
			}

			public void onVolumeChanged(final float volumn) {
				callLuaInGLThread("onVoiceVolumeChanged", "" + volumn);
			}

			public void onError(final String errStr) {
				callLuaInGLThread("onVoiceError", errStr);
			}

			public void onPlayVoiceFinish() {
				callLuaInGLThread("onPlayVoiceFinish", "");
			}

			public void onRecordFinish() {
				callLuaInGLThread("onPlayVoiceFinish", "");
			}

			// 客户端请求accessToken时 用
			public void setAccessToken(final String accessToken) {
				callLuaInGLThread("setAccessToken", accessToken);
			}

			// 上传返回
			public void onVoicePut(final String succ) {
				callLuaInGLThread("onVoicePut", succ);
			}

			// 下载返回
			public void onVoiceGet(final String succ) {
				callLuaInGLThread("onVoiceGet", succ);
			}

		});
	}

	public static void requestRecognize(final File file, final long len) {
		sContext.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				String resultStr = VoiceHttpRequest.getInstance().requestRecognizeHide(file, len);
				Log.i(TAG, "语音结果  = " + resultStr);
				VoiceManagement.getInstance().getVoiceCallBackListener().onResult(resultStr);
			}
		});

	}
	
	static Handler requestHandler = new Handler() {  
	    @Override  
	    public void handleMessage(Message msg) {  
	        super.handleMessage(msg);  
	        Bundle data = msg.getData();  
	        String resultStr = data.getString("result");  
			VoiceManagement.getInstance().getVoiceCallBackListener().onResult(resultStr);
			Log.i(TAG, "语音结果22  = " + resultStr);
	        // TODO  
	        // UI界面的更新等相关操作  
	    }  
	};  
	  
	/** 
	 * 网络操作相关的子线程 
	 */  
	public static  class RequestTask extends Thread
	{
		private File file;
		private long len;
		public RequestTask(File file, long len)
		{
			this.file = file;
			this.len = len;
		}
		public void run() {  
			String resultStr = VoiceHttpRequest.getInstance().requestRecognizeHide(file, len);
			Log.i(TAG, "语音结果11  = " + resultStr);

	        Message msg = new Message();  
	        Bundle data = new Bundle();  
	        data.putString("result", resultStr); 
	        msg.setData(data);  
	        
	        requestHandler.sendMessage(msg);  
	    }  
	}
	public static void requestRecognizeNew(final File file, final long len) {
		new Thread(new RequestTask(file, len)).start();
	}
}
