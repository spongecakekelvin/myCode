package org.cocos2dx.lib;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.content.DialogInterface;
import android.view.View.OnClickListener;
import android.os.Bundle;
import android.os.Environment;
import android.os.Message;
import android.view.ViewGroup;
import android.util.Log;
import android.net.Uri;
import android.app.AlertDialog;
import java.io.File;
import java.io.IOException;
import android.widget.FrameLayout;
import android.preference.PreferenceManager.OnActivityResultListener;
import android.view.WindowManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import android.os.StatFs;
import android.view.Surface;

class CCNetBroadcastReceiver extends BroadcastReceiver{
	public  int luacallback_net = 0;
	public void onReceive(Context context, Intent intent)
	{
		ConnectivityManager connectMgr = (ConnectivityManager) ((Cocos2dxActivity)context).getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo mobNetInfo = connectMgr
				.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		NetworkInfo wifiNetInfo = connectMgr
				.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		
			if (luacallback_net>0)
			{
				if(wifiNetInfo!=null && wifiNetInfo.isConnected())
				{
					
					((Cocos2dxActivity)context).runOnGLThread(new Runnable() {
			            public void run() {
			                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
			                		"wifi_net");
			            }
			        });
					
				}
				else if(mobNetInfo!=null && mobNetInfo.isConnected())
				{
					
					((Cocos2dxActivity)context).runOnGLThread(new Runnable() {
			            public void run() {
			                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
			                		"mobile_net");
			            }
			        });
					
				}
				else
				{
					((Cocos2dxActivity)context).runOnGLThread(new Runnable() {
			            public void run() {
			                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luacallback_net,
			                		"no_net");
			            }
			        });
					
				}

			}
		
	}
}