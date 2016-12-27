package com.kelvin.demo;

import java.util.HashMap;

import android.app.Activity;
import android.content.Context;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo.State;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import android.util.Log;

public class NetUtil {
	public static final int NETWORN_NONE = 0;
	public static final int NETWORN_WIFI = 1;
	public static final int NETWORN_MOBILE = 2;
	public static String mobileStrength = "0";
	private static Activity _activity = null;
	private static TelephonyManager telephoneManager = null;
	
	private final static HashMap<Integer, String> StateName = new HashMap<Integer, String>() {
		{
			put(NETWORN_NONE, "无网络");
			put(NETWORN_WIFI, "WIFI");
			put(NETWORN_MOBILE, "移动网络");
		}
	};
	/**
	 * 需要第一个调用的初始化函数
	 */
	public static void setContent(Activity appActivity) {
		_activity = appActivity;
		telephoneManager = (TelephonyManager)_activity.getSystemService(Context.TELEPHONY_SERVICE);
		telephoneManager.listen(phoneStateListener,  
                PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);  

	}
	
	/**
	 * 初始化广播接收器
	 */
	public static void initRecevier(Context context, NetBroadcastReceiver installReceiver) {
		// 注册apk安装卸载广播
		IntentFilter filter = new IntentFilter();
		filter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
//		filter.addAction("android.intent.action.PACKAGE_ADDED");
//		filter.addAction("android.intent.action.PACKAGE_REMOVED");
//		filter.addDataScheme("package");
		context.registerReceiver(installReceiver, filter);
	}
	public static int getNetworkState(Context context) {
		ConnectivityManager connManager = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		 
		// Wifi
		State state = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
				.getState();
		if (state == State.CONNECTED || state == State.CONNECTING) {
			return NETWORN_WIFI;
		}

		// 3G
		state = connManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
				.getState();
		if (state == State.CONNECTED || state == State.CONNECTING) {
			return NETWORN_MOBILE;
		}
		return NETWORN_NONE;
	}

	public static String getNetworkStateName(int state) {
		return StateName.get(state);
	}
	

	 public static int getWifiStrength(Context context) {  
           WifiManager wifiManager = (WifiManager) context.getSystemService(context.WIFI_SERVICE);  
           WifiInfo wifiInfo = wifiManager.getConnectionInfo();  
           int signalLevel = 0;
           if (wifiInfo.getBSSID() != null) {  
               //wifi名称  
               String ssid = wifiInfo.getSSID();  
               //wifi信号强度  
//               signalLevel = WifiManager.calculateSignalLevel(wifiInfo.getRssi(), 5);  
               signalLevel = Math.abs(wifiInfo.getRssi()); 
               //wifi速度  
               int speed = wifiInfo.getLinkSpeed();  
               //wifi速度单位  
               String units = WifiInfo.LINK_SPEED_UNITS;  
//               System.out.println("ssid="+ssid+",signalLevel="+signalLevel+",speed="+speed+",units="+units);  
           }  
           return signalLevel;
      } 
	 
	 public static int getStrength(Context context) {
		 int signalLevel = Integer.parseInt(NetUtil.mobileStrength);
		 Log.d(Global.TAG, "NetUtil getStrength = " + signalLevel);
		 return  signalLevel;
	 }
	 
	 static PhoneStateListener phoneStateListener = new PhoneStateListener() {  
         @Override  
         public void onSignalStrengthsChanged(SignalStrength signalStrength) {  
             // TODO Auto-generated method stub  
             super.onSignalStrengthsChanged(signalStrength);  
             
             final int type = telephoneManager.getNetworkType(); 
             
             
             StringBuffer sb = new StringBuffer();  
             String strength = String.valueOf(signalStrength  
                     .getGsmSignalStrength());  
             if (type == TelephonyManager.NETWORK_TYPE_UMTS  
                     || type == TelephonyManager.NETWORK_TYPE_HSDPA) {  
                 sb.append("联通3g").append("信号强度:").append(strength);  
             } else if (type == TelephonyManager.NETWORK_TYPE_GPRS  
                     || type == TelephonyManager.NETWORK_TYPE_EDGE) {  
                 sb.append("移动或者联通2g").append("信号强度:").append(strength);  
             }else if(type==TelephonyManager.NETWORK_TYPE_CDMA){  
                 sb.append("电信2g").append("信号强度:").append(strength);  
             }else if(type==TelephonyManager.NETWORK_TYPE_EVDO_0  
                     ||type==TelephonyManager.NETWORK_TYPE_EVDO_A){  
                 sb.append("电信3g").append("信号强度:").append(strength);  
                   
             }else{  
                 sb.append("非以上信号").append("信号强度:").append(strength);  
             }  
             NetUtil.mobileStrength = strength;

             Log.d(Global.TAG, "onSignalStrengthsChanged = " + type + ", " + telephoneManager.getPhoneType() +","+ strength + ", " + sb.toString());
             ((SDKDemoMainActivity) _activity).onNetChange();
//             Toast.make(context, sb.toString());  
//             Toast.show();  
         }  

     }; 

}