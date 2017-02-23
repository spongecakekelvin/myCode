package org.cocos2dx.lib;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class Cocos2dxAlarmManager {
    public static void alarmNotify(Context Context, String jsonString)
    {
        AlarmManager localAlarmManager = (AlarmManager)Context.getSystemService(android.content.Context.ALARM_SERVICE);
        
        String countTimeType = "rtc";
        long intervalAtMillis = 86400;
        long triggerAtMillis = System.currentTimeMillis() / 1000L;
        int type = AlarmManager.RTC;
        PendingIntent localPendingIntent;

        try
        {
          JSONObject localJSONObject = new JSONObject(jsonString);
          String packageName = localJSONObject.optString("packageName",Context.getPackageName());
          String ticker = localJSONObject.optString("ticker", "null");
          String title = localJSONObject.optString("title", "null");
          String text = localJSONObject.optString("text", "null");
          String str1 = localJSONObject.optString("tag", "noonce");
          triggerAtMillis = localJSONObject.optLong("triggerAtMillis", System.currentTimeMillis() / 1000L);
          long triggerOffset = localJSONObject.optLong("triggerOffset", 0L);
          intervalAtMillis = localJSONObject.optLong("intervalAtMillis", 0);
          countTimeType = localJSONObject.optString("countTimeType", "rtc");
          triggerAtMillis *= 1000L;
          long triggerOffsetMillis = triggerOffset * 1000L;
          intervalAtMillis *= 1000L;
          int id = localJSONObject.optInt("id", 0);


          if (triggerOffsetMillis > 0L)
              triggerAtMillis += triggerOffsetMillis;
//          if (!countTimeType.equals("rtc"))
//            return;

          Intent localIntent = new Intent("com.s3arpg.game_receiver");//广播名，时间到了就会发送game_receiver
          Bundle localBundle = new Bundle();
          localBundle.putInt("flag", id);
          localBundle.putString("packageName", packageName);
          localBundle.putString("ticker", ticker);
          localBundle.putString("title", title);
          localBundle.putString("text", text);
          localIntent.putExtras(localBundle);
          localPendingIntent = PendingIntent.getBroadcast(Context, id, localIntent, PendingIntent.FLAG_UPDATE_CURRENT);
          if (str1.equals("once"))
          {
              localAlarmManager.set(type, triggerAtMillis, localPendingIntent);
          }
          else
          {
              localAlarmManager.setRepeating(type , triggerAtMillis, intervalAtMillis, localPendingIntent); 
          }

//            Intent localIntent1 = new Intent("com.s3arpg.game_receiver");
//            PendingIntent localPendingIntent1 = PendingIntent.getBroadcast(Context, 0, localIntent, 0);
          long sss = System.currentTimeMillis();
          sss += 10000;   
          Log.v("MyService","Cocos2dxAlarmManager "+(System.currentTimeMillis()-triggerAtMillis));
          
//            localAlarmManager.set(AlarmManager.RTC_WAKEUP , triggerAtMillis, localPendingIntent);
//            localAlarmManager.setRepeating(AlarmManager.RTC_WAKEUP , System.currentTimeMillis(), 5000, localPendingIntent); 
        }
        catch (JSONException localJSONException)
        {
//          localJSONException.printStackTrace();
//
//          if (countTimeType.equals("rtc_wakeup"))
//              type = AlarmManager.RTC_WAKEUP;
//          if (countTimeType.equals("elapsed_wakeup"))
//              type = AlarmManager.ELAPSED_REALTIME_WAKEUP;
//          type = AlarmManager.ELAPSED_REALTIME;
//          
//          localAlarmManager.setRepeating(type, triggerAtMillis, intervalAtMillis, localPendingIntent);
        }
    }
    
    public static void cancelNotify(Context paramContext, int paramInt)
      {
        NotificationManager localNotificationManager = (NotificationManager)paramContext.getSystemService("notification");
        localNotificationManager.cancel(paramInt);
        
        AlarmManager localAlarmManager = (AlarmManager)paramContext.getSystemService(android.content.Context.ALARM_SERVICE);
        PendingIntent localPendingIntent = PendingIntent.getBroadcast(paramContext, paramInt, new Intent("com.s3arpg.game_receiver"), PendingIntent.FLAG_NO_CREATE);
        if (localPendingIntent == null)
          return;
        localAlarmManager.cancel(localPendingIntent);
      }

      public static void cancelNotify(Context paramContext, String paramString)
      {
        AlarmManager localAlarmManager = (AlarmManager)paramContext.getSystemService(android.content.Context.ALARM_SERVICE);
        try
        {
          JSONArray localJSONArray = new JSONObject(paramString).optJSONArray("piids");
          int i = 0;
          if (i >= localJSONArray.length())
            return;
          PendingIntent localPendingIntent = PendingIntent.getBroadcast(paramContext, localJSONArray.getInt(i), new Intent("com.s3arpg.game_receiver"), PendingIntent.FLAG_NO_CREATE);
          if (localPendingIntent != null)
            localAlarmManager.cancel(localPendingIntent);
          ++i;
        }
        catch (JSONException localJSONException)
        {
          localJSONException.printStackTrace();
        }
      }
}