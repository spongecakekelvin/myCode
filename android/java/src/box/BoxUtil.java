package box;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Environment;
import android.widget.Toast;

public class BoxUtil {

	/**
	 * 初始化安装广播接收器
	 * 
	 * @param context
	 * @param installReceiver
	 */
	public static void initApkRecevier(Context context, BoxInstallReceiver installReceiver) {
		// 注册apk安装卸载广播
		IntentFilter filter = new IntentFilter();
		filter.addAction("android.intent.action.PACKAGE_ADDED");
		filter.addAction("android.intent.action.PACKAGE_REMOVED");
		filter.addDataScheme("package");
		context.registerReceiver(installReceiver, filter);
	}

	/**
	 * @param context
	 *            例如MainActivity.this
	 */
	public static void installGameBox(Context context) {
		String sdState = Environment.getExternalStorageState();// 获得sd卡的状态״̬
		if (!sdState.equals(Environment.MEDIA_MOUNTED)) { // 判断SD卡是否存在
			// 提示sd卡不存在
			Toast.makeText(context, "sd卡不可用", Toast.LENGTH_SHORT).show();
			return;
		}
		// 先将assets中APK文件添加到SD卡中 根据SD卡路径进行安装
		if (copyApkFromAssets(context, "KKGameBox.apk", Environment.getExternalStorageDirectory().getAbsolutePath()
				+ File.separator + "/KKGameBox.apk")) {
			try {
				installApp(context, Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator
						+ "/KKGameBox.apk");
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else {
			Toast.makeText(context, "不存在该路径", Toast.LENGTH_SHORT).show();
		}
	}

	/**
	 * 将assets中的APK文件添加到SD卡中 许在配置文件中添加此权限<uses-permission
	 * android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
	 * 
	 * @param context
	 * @param fileName
	 * @param path
	 * @return
	 */
	private static boolean copyApkFromAssets(Context context, String fileName, String path) {
		boolean copyIsFinish = false;
		try {
			InputStream is = context.getAssets().open(fileName);
			File file = new File(path);
			file.createNewFile();
			FileOutputStream fos = new FileOutputStream(file);
			byte[] temp = new byte[1024];
			int i = 0;
			while ((i = is.read(temp)) > 0) {
				fos.write(temp, 0, i);
			}
			fos.close();
			is.close();
			copyIsFinish = true;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return copyIsFinish;
	}

	/**
	 * 安装APK文件
	 * 
	 * @param filePath
	 */
	private static void installApp(Context context, String filePath) throws Exception {
		try {
			File file = new File(filePath);
			if (file != null && !file.exists()) {
				Toast.makeText(context, "数据文件被损坏，无法安装", Toast.LENGTH_SHORT).show();
				throw new Exception("文件不存在");
			}
			Intent intent = new Intent();
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.setAction(android.content.Intent.ACTION_VIEW);
			intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive");
			context.startActivity(intent);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
