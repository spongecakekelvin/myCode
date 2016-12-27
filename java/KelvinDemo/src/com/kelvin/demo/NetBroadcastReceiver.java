package com.kelvin.demo;

import java.util.ArrayList;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.util.Log;

public class NetBroadcastReceiver extends BroadcastReceiver {
    public static ArrayList<netEventHandler> mListeners = new ArrayList<netEventHandler>();
    private static String NET_CHANGE_ACTION = "android.net.conn.CONNECTIVITY_CHANGE";
//    private static String WIFI_STATE_CHANGED_ACTION = "android.net.wifi.WIFI_STATE_CHANGED";
    @Override
    
    public void onReceive(Context context, Intent intent) {
    	// 通知接口完成加载
    	if (mListeners.size() > 0) {
    		Log.d(Global.TAG, "intent.getAction = " + intent.getAction());
	        if (intent.getAction().equals(NET_CHANGE_ACTION) || 
	        	intent.getAction().equals(WifiManager.WIFI_STATE_CHANGED_ACTION)) {
	                for (netEventHandler handler : mListeners) {
	                    handler.onNetChange();
	                }
//	        }else if (intent.getAction().equals(WifiManager.WIFI_STATE_CHANGED_ACTION)){
	        }
    	}
    }

    public static abstract interface netEventHandler {

        public abstract void onNetChange();
    }
    
// // 声明wifi消息处理过程  
//    private BroadcastReceiver wifiIntentReceiver = new BroadcastReceiver() {  
//    @Override 
//    public void onReceive(Context context, Intent intent) {  
//        int wifi_state = intent.getIntExtra("wifi_state", 0);  
//        int level = Math.abs(((WifiManager)getSystemService(WIFI_SERVICE)).getConnectionInfo().getRssi()); 
//        Log.i(Global.TAG, "1111:" + level);  
//        switch (wifi_state) {  
//        case WifiManager.WIFI_STATE_DISABLING:  
//          Log.i(Global.TAG, "1111:" + WifiManager.WIFI_STATE_DISABLING);  
//          break;  
//        case WifiManager.WIFI_STATE_DISABLED:  
//          Log.i(Global.TAG, "2222:" + WifiManager.WIFI_STATE_DISABLED);  
//          break;  
//        case WifiManager.WIFI_STATE_ENABLING:  
//          Log.i(Global.TAG, "33333:" + WifiManager.WIFI_STATE_ENABLING);  
//          break;  
//        case WifiManager.WIFI_STATE_ENABLED:  
//          Log.i(Global.TAG, "4444:" + WifiManager.WIFI_STATE_ENABLED);  
//          break;  
//        case WifiManager.WIFI_STATE_UNKNOWN:  
//          Log.i(Global.TAG, "5555:" + WifiManager.WIFI_STATE_UNKNOWN);  
//          break;  
//        }  
//      }  
//    }; 
    
}