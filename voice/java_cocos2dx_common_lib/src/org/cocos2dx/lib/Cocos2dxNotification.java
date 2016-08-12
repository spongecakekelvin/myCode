package org.cocos2dx.lib;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

public class Cocos2dxNotification
{
	public static void doNotify(Context paramContext, String packageName,
			String ticker, String title, String text, int id)
	{
		int icon = paramContext.getResources().getIdentifier("icon", "drawable", paramContext.getPackageName());
//		int icon = 0x7f020014;

		NotificationManager localNotificationManager = (NotificationManager) paramContext
				.getSystemService("notification");
		NotificationCompat.Builder localBuilder = new NotificationCompat.Builder(
				paramContext);
		localBuilder.setSmallIcon(icon);
		localBuilder.setTicker(ticker);
		localBuilder.setContentTitle(title);
		localBuilder.setContentText(text);
		localBuilder.setAutoCancel(true);
		try
		{
			Log.v("MyService", packageName);
			Log.v("MyService", Class.forName(packageName).toString());
			Intent localIntent = new Intent(paramContext,
					Class.forName(packageName));
			localIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			localIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
			localBuilder.setContentIntent(PendingIntent.getActivity(
					paramContext, 0, localIntent, PendingIntent.FLAG_ONE_SHOT));
			Notification notfi = localBuilder.build();
			notfi.defaults = Notification.DEFAULT_SOUND;
			notfi.defaults |= Notification.DEFAULT_VIBRATE;
			notfi.defaults |= Notification.DEFAULT_LIGHTS;
			localNotificationManager.notify(id, notfi);
			return;
		} catch (ClassNotFoundException localClassNotFoundException)
		{
			localClassNotFoundException.printStackTrace();
		}
	}
}