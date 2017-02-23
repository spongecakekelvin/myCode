package box;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public abstract class BoxInstallReceiver extends BroadcastReceiver {

	public void onReceive(final Context context, Intent intent) {
		final String action = intent.getAction();
		final String packageName = intent.getDataString().substring(8);
		if (action.equals(Intent.ACTION_PACKAGE_ADDED)) { // install
			if (packageName.equals("com.jooyuu.kkgamebox")) {// KK游戏包名
				onInstalledBox(context);
			}
		} else if (action.equals(Intent.ACTION_PACKAGE_REMOVED)) { // uninstall
			onRemovedBox(context);
		}
	}

	public abstract void onInstalledBox(Context context);
	public abstract void onRemovedBox(Context context);

}
