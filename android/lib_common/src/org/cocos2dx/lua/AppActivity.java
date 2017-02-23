/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
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
package org.cocos2dx.lua;

import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;

import utils.SignUtils;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.view.WindowManager;

import com.jooyuu.fusionsdk.FusionSDK;
import com.jooyuu.sdk.FusionSdkUtils;

// The name of .so is specified in AndroidMenifest.xml. NativityActivity will load it automatically for you.
// You can use "System.loadLibrary()" to load other .so files.

public class AppActivity extends Cocos2dxActivity {

	// 商户PID
	public static String PARTNER = "";
	// 商户收款账号
	public static String SELLER = "";
	// 商户私钥，pkcs8格式
	public static String RSA_PRIVATE = "";

	private static final int SDK_PAY_FLAG = 1;

	private static final int SDK_CHECK_FLAG = 2;

	private boolean isFirstLogin = false;   
	
	static String hostIPAdress = "0.0.0.0";
	public static AppActivity s_oActivityInstance = null;
	// private ProgressDialog dlg;

	private static final String TAG = "s3arpgTAG";

	private static ProgressDialog mAutoLoginWaitingDlg = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		// MSDK
		s_oActivityInstance = this;
		FusionSdkUtils.initCreate(this);

		if (nativeIsLandScape()) {
			// setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
		} else {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
		}

		// 2.Set the format of window

		// Check the wifi is opened when the native is debug.
		if (nativeIsDebug()) {
			getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
					WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
			if (!isNetworkConnected()) {
				AlertDialog.Builder builder = new AlertDialog.Builder(this);
				builder.setTitle("Warning");
				builder.setMessage("Open Wifi for debuging...");
				builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
						finish();
						System.exit(0);
					}
				});
				builder.setCancelable(false);
				builder.show();
			}
		}
		hostIPAdress = getHostIpAddress();
		
		FusionSdkUtils.initSDK("xxxxx"); // 此处不用改，用于脚本匹配
	}


	private boolean isNetworkConnected() {
		ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		if (cm != null) {
			NetworkInfo networkInfo = cm.getActiveNetworkInfo();
			ArrayList networkTypes = new ArrayList();
			networkTypes.add(ConnectivityManager.TYPE_WIFI);
			try {
				networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
			} catch (NoSuchFieldException nsfe) {
			} catch (IllegalAccessException iae) {
				throw new RuntimeException(iae);
			}
			if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
				return true;
			}
		}
		return false;
	}

	public String getHostIpAddress() {
		WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
		WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
		int ip = wifiInfo.getIpAddress();
		return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
	}

	public static String getLocalIpAddress() {
		return hostIPAdress;
	}

	public static String getSDCardPath() {
		if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
			String strSDCardPathString = Environment.getExternalStorageDirectory().getPath();
			return strSDCardPathString;
		}
		return null;
	}



	// 重新登录游戏
	public static void restartGame() {
		s_oActivityInstance.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				AppActivity.s_oActivityInstance.restart();
			}
		});

	}

	public void restart() {
		Intent intent = new Intent(AppActivity.s_oActivityInstance, AppActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		AppActivity.s_oActivityInstance.startActivity(intent);
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	// 进入游戏
	private void startGame() {
		s_oActivityInstance.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivity.callLuaGlobalFunction("SetLoginPlat", "909");
			}
		});
	}
	public static void arpgexit(final String tipTemp, final String contentTemp,
			final String leftstrTemp, final String rightstrTemp) {
		s_oActivityInstance.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				boolean succ = FusionSdkUtils.exitSDK();
				if (!succ){
					Cocos2dxActivity.arpgexit(tipTemp, contentTemp, leftstrTemp, rightstrTemp);
				}
			}
		});
		
	}


	private void notifyInvalidLocalInfo() {
		s_oActivityInstance.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivity.callLuaGlobalFunction("invalidlocalinfo", "");
			}
		});
	}


	private static native boolean nativeIsLandScape();

	private static native boolean nativeIsDebug();


	/**
	 * sign the order info. 对订单信息进行签名
	 * 
	 * @param content
	 *            待签名订单信息
	 */
	public static String sign(String content) {
		return SignUtils.sign(content, RSA_PRIVATE);
	}

	/**
	 * get the sign type we use. 获取签名方式
	 * 
	 */
	public static String getSignType() {
		return "sign_type=\"RSA\"";
	}

	public static void rebootApp() {

		// System.exit(0);
		// Intent intent = new Intent(s_oActivityInstance, AppActivity.class);
		// intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP |
		// Intent.FLAG_ACTIVITY_NEW_TASK);
		// s_oActivityInstance.startActivity(intent);

	}
	@Override
	protected void onStart() {
		super.onStart();
		FusionSDK.getInstance().onStart(s_oActivityInstance);
	}
	
	@Override
	protected void onRestart() {
		super.onRestart();
		FusionSDK.getInstance().onRestart(s_oActivityInstance);
	}

	@Override
	protected void onResume() {
		super.onResume();
		FusionSDK.getInstance().onResume(s_oActivityInstance);
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		FusionSDK.getInstance().onPause(s_oActivityInstance);
	}
	
	@Override
	protected void onStop() {
		super.onPause();
		FusionSDK.getInstance().onStop(s_oActivityInstance);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		FusionSDK.getInstance().onDestroy(s_oActivityInstance);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data){
		super.onActivityResult(requestCode, resultCode, data);
		FusionSDK.getInstance().onActivityResult(s_oActivityInstance, requestCode, resultCode, data);
	}
	
	
	// TODO GAME 在onNewIntent中需要调用handleCallback将平台带来的数据交给FusionSDK处理
	@Override
	protected void onNewIntent(Intent intent){
		FusionSDK.getInstance().onNewIntent(intent);
	}
	
	

}
