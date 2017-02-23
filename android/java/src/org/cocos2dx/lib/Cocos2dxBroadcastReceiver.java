package org.cocos2dx.lib;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningServiceInfo;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class Cocos2dxBroadcastReceiver extends BroadcastReceiver
{

    @Override
    public void onReceive(Context context, Intent intent) {
        // TODO Auto-generated method stub
    	

        if(intent.getAction().equals("com.s3arpg.game_receiver"))
        {
            Log.v("MyService","Cocos2dxPushService onReceive"); 
            Bundle localBundle = intent.getExtras();
            int flag = localBundle.getInt("flag");
            String packageName = localBundle.getString("packageName");
            String ticker = localBundle.getString("ticker");
            String title = localBundle.getString("title");
            String text = localBundle.getString("text");
            int id = localBundle.getInt("id");
            Log.v("MyService","Cocos2dxPushService onReceive2  "+packageName); 
            Cocos2dxNotification.doNotify(context, packageName, ticker, title, text,id);//开始本地推送
        }
    }
}