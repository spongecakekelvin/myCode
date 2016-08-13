package com.jooyuu;

import java.io.File;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.os.Environment;
import android.telephony.TelephonyManager;
import android.util.Log;

public class BaseGameUtil {
	/**
	 * 获取SD卡的路径
	 * 
	 * @return
	 */
	public static String getSDPath() {
		/** SD卡是否存在 **/
		boolean hasSD = false;

		/** SD卡的路径 **/
		String sdPath;

		hasSD = Environment.getExternalStorageState().equals(
				android.os.Environment.MEDIA_MOUNTED);
		if (hasSD) {
			sdPath = Environment.getExternalStorageDirectory().getPath();
		} else {
			sdPath = "";
		}

		return sdPath;
	}

	/**
	 * 获取手机型号信息
	 * 
	 * @return
	 */
	public static String getPhoneInfo() {

		String phoneInfo = android.os.Build.MANUFACTURER

		+ "/" + android.os.Build.MODEL

		+ "/" + android.os.Build.HARDWARE + "/" + android.os.Build.HOST + "/"
				+ android.os.Build.ID

				+ "/" + android.os.Build.VERSION.RELEASE;

		return phoneInfo;
	}

	/**
	 * 获取SIM卡IEMI
	 * 
	 * @param context
	 * @return
	 */
	public static String getPhoneIMEI(Context context) {
		String phoneIMEI = ((TelephonyManager) context
				.getSystemService(context.TELEPHONY_SERVICE)).getDeviceId();

		return phoneIMEI;
	}

	/**
	 * 获取设备ID
	 * 
	 * @param context
	 * @return
	 */
	public static String getHardwareId(Context context) {
		String hardwareId = android.provider.Settings.Secure.getString(
				context.getContentResolver(),
				android.provider.Settings.Secure.ANDROID_ID);

		return hardwareId;
	}

	/**
	 * 判断当前是否使用的是 WIFI网络
	 * 
	 * @param _para
	 * @param context
	 * @return
	 */
	public static int isWifiActive(int _para, Context context) {
		ConnectivityManager connectivity = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo[] info;
		if (connectivity != null) {
			info = connectivity.getAllNetworkInfo();
			if (info != null) {
				for (int i = 0; i < info.length; i++) {
					if (info[i].getTypeName().equals("WIFI")
							&& info[i].isConnected()) {
						return 1;
					}
				}
			}
		}
		return 0;
	}

	/**
	 * 获取wifi的ip地址
	 * 
	 * @param wifiInfo
	 * @return
	 */
	public static String getWifiIpAddress(WifiInfo wifiInfo) {
		int ipAddress = wifiInfo.getIpAddress();
		String ip = intToIp(ipAddress);
		return ip;
	}

	private static String intToIp(int i) {
		return (i & 0xFF) + "." + ((i >> 8) & 0xFF) + "." + ((i >> 16) & 0xFF)
				+ "." + (i >> 24 & 0xFF);
	}
	
	/**
	 * 获取GPRS的ip地址
	 * 
	 * @return
	 */
	public static String getGPRSIpAddress() {
		try {
			for (Enumeration<NetworkInterface> en = NetworkInterface
					.getNetworkInterfaces(); en.hasMoreElements();) {
				NetworkInterface intf = en.nextElement();
				for (Enumeration<InetAddress> enumIpAddr = intf
						.getInetAddresses(); enumIpAddr.hasMoreElements();) {
					InetAddress inetAddress = enumIpAddr.nextElement();
					if (!inetAddress.isLoopbackAddress()) {
						return inetAddress.getHostAddress().toString();
					}
				}
			}
		} catch (SocketException ex) {
			Log.e("WifiPreference IpAddress", ex.toString());
		}
		return null;
	}

	public static void openUrl(String url, Context context) {
		Intent it = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
		context.startActivity(it);
	}

	/**
	 * 自动安装
	 * 
	 * @param path
	 * @param context
	 */
	public static void autoInstall(String path, Context context) {
		File file = new File(path);
		Intent intent = new Intent();
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.setAction(android.content.Intent.ACTION_VIEW);
		intent.setDataAndType(Uri.fromFile(file),
				"application/vnd.android.package-archive");
		context.startActivity(intent);
	}

	/**
	 * 充值成功之后的回调函数
	 * 
	 * @param orderID
	 */
	public static void afterPaySuccess(String orderID) {
	}

}
