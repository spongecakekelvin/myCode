package com.kelvin.demo;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.util.Log;

public class Util {

	private static Activity _activity = null;
	private static TelephonyManager telephoneManager = null;

	public static void setContent(Activity appActivity) {
		_activity = appActivity;
		telephoneManager = (TelephonyManager) _activity
				.getSystemService(Context.TELEPHONY_SERVICE);
	}

	public static String getTelephoneInfo() {
		StringBuilder sb = new StringBuilder();
		String ret = "";
		sb.append("/nDeviceId(IMEI) = " + telephoneManager.getDeviceId()); // 设备Id
		sb.append("/nDeviceSoftwareVersion = "
				+ telephoneManager.getDeviceSoftwareVersion());
		sb.append("/nLine1Number = " + telephoneManager.getLine1Number());
		sb.append("/nNetworkCountryIso = "
				+ telephoneManager.getNetworkCountryIso());
		sb.append("/nNetworkOperator = "
				+ telephoneManager.getNetworkOperator());
		sb.append("/nNetworkOperatorName = "
				+ telephoneManager.getNetworkOperatorName());
		sb.append("/nNetworkType = " + telephoneManager.getNetworkType());
		sb.append("/nPhoneType = " + telephoneManager.getPhoneType());
		sb.append("/nSimCountryIso = " + telephoneManager.getSimCountryIso());
		sb.append("/nSimOperator = " + telephoneManager.getSimOperator());
		sb.append("/nSimOperatorName = "
				+ telephoneManager.getSimOperatorName());
		sb.append("/nSimSerialNumber = "
				+ telephoneManager.getSimSerialNumber());
		sb.append("/nSimState = " + telephoneManager.getSimState());
		sb.append("/nSubscriberId(IMSI) = "
				+ telephoneManager.getSubscriberId());
		sb.append("/nVoiceMailNumber = "
				+ telephoneManager.getVoiceMailNumber());

		Log.e(Global.TAG,
				"/nDeviceId(IMEI) = " + telephoneManager.getDeviceId()); // 设备Id
		Log.e(Global.TAG,
				"/nDeviceSoftwareVersion = "
						+ telephoneManager.getDeviceSoftwareVersion());
		Log.e(Global.TAG,
				"/nLine1Number = " + telephoneManager.getLine1Number());
		Log.e(Global.TAG,
				"/nNetworkCountryIso = "
						+ telephoneManager.getNetworkCountryIso());
		Log.e(Global.TAG,
				"/nNetworkOperator = " + telephoneManager.getNetworkOperator());
		Log.e(Global.TAG,
				"/nNetworkOperatorName = "
						+ telephoneManager.getNetworkOperatorName());
		Log.e(Global.TAG,
				"/nNetworkType = " + telephoneManager.getNetworkType());
		Log.e(Global.TAG, "/nPhoneType = " + telephoneManager.getPhoneType());
		Log.e(Global.TAG,
				"/nSimCountryIso = " + telephoneManager.getSimCountryIso());
		Log.e(Global.TAG,
				"/nSimOperator = " + telephoneManager.getSimOperator());
		Log.e(Global.TAG,
				"/nSimOperatorName = " + telephoneManager.getSimOperatorName());
		Log.e(Global.TAG,
				"/nSimSerialNumber = " + telephoneManager.getSimSerialNumber());
		Log.e(Global.TAG, "/nSimState = " + telephoneManager.getSimState());
		Log.e(Global.TAG,
				"/nSubscriberId(IMSI) = " + telephoneManager.getSubscriberId());
		Log.e(Global.TAG,
				"/nVoiceMailNumber = " + telephoneManager.getVoiceMailNumber());

		// 获取手机号码
		String phoneNumber = telephoneManager.getLine1Number();
		Log.e("获取本机电话号码--->", phoneNumber);

		// 获取手机型号
		String phoneModel = Build.MODEL;
		Log.e("获取手机型号--->", phoneModel);

		// 获取SDK版本
		String phoneSdkVersion = String.valueOf(Build.VERSION.SDK_INT);
		Log.e("获取SDK版本--->", phoneSdkVersion);

		// 获取系统版本
		String phoneReleaseVersion = Build.VERSION.RELEASE;
		Log.e("获取手机系统版本-->", phoneReleaseVersion);

		ret = sb.toString();
		return ret;
	}

	public static String getDeviceInf() {
		StringBuilder sb = new StringBuilder();
		sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
		sb.append("BOARD ").append(android.os.Build.BOARD).append("\n");
		sb.append("BOOTLOADER ").append(android.os.Build.BOOTLOADER)
				.append("\n");
		sb.append("BRAND ").append(android.os.Build.BRAND).append("\n");
		sb.append("CPU_ABI ").append(android.os.Build.CPU_ABI).append("\n");
		sb.append("CPU_ABI2 ").append(android.os.Build.CPU_ABI2).append("\n");
		sb.append("DEVICE ").append(android.os.Build.DEVICE).append("\n");
		sb.append("DISPLAY ").append(android.os.Build.DISPLAY).append("\n");
		sb.append("FINGERPRINT ").append(android.os.Build.FINGERPRINT)
				.append("\n");
		sb.append("HARDWARE ").append(android.os.Build.HARDWARE).append("\n");
		sb.append("HOST ").append(android.os.Build.HOST).append("\n");
		sb.append("ID ").append(android.os.Build.ID).append("\n");
		sb.append("MANUFACTURER ").append(android.os.Build.MANUFACTURER)
				.append("\n");
		sb.append("MODEL ").append(android.os.Build.MODEL).append("\n");
		sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
		sb.append("RADIO ").append(android.os.Build.RADIO).append("\n");
		sb.append("SERIAL ").append(android.os.Build.SERIAL).append("\n");
		sb.append("TAGS ").append(android.os.Build.TAGS).append("\n");
		sb.append("TIME ").append(android.os.Build.TIME).append("\n");
		sb.append("TYPE ").append(android.os.Build.TYPE).append("\n");
		sb.append("USER ").append(android.os.Build.USER).append("\n");

		sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
		sb.append("BOARD ").append(android.os.Build.BOARD).append("\n");
		sb.append("BOOTLOADER ").append(android.os.Build.BOOTLOADER)
				.append("\n");
		sb.append("BRAND ").append(android.os.Build.BRAND).append("\n");
		sb.append("CPU_ABI ").append(android.os.Build.CPU_ABI).append("\n");
		sb.append("CPU_ABI2 ").append(android.os.Build.CPU_ABI2).append("\n");
		sb.append("DEVICE ").append(android.os.Build.DEVICE).append("\n");
		sb.append("DISPLAY ").append(android.os.Build.DISPLAY).append("\n");
		sb.append("FINGERPRINT ").append(android.os.Build.FINGERPRINT)
				.append("\n");
		sb.append("HARDWARE ").append(android.os.Build.HARDWARE).append("\n");
		sb.append("HOST ").append(android.os.Build.HOST).append("\n");
		sb.append("ID ").append(android.os.Build.ID).append("\n");
		sb.append("MANUFACTURER ").append(android.os.Build.MANUFACTURER)
				.append("\n");
		sb.append("MODEL ").append(android.os.Build.MODEL).append("\n");
		sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
		sb.append("RADIO ").append(android.os.Build.RADIO).append("\n");
		sb.append("SERIAL ").append(android.os.Build.SERIAL).append("\n");
		sb.append("TAGS ").append(android.os.Build.TAGS).append("\n");
		sb.append("TIME ").append(android.os.Build.TIME).append("\n");
		sb.append("TYPE ").append(android.os.Build.TYPE).append("\n");
		sb.append("USER ").append(android.os.Build.USER).append("\n");

		String result = sb.toString() + "#####";

		result = result + android.os.Build.MODEL + ","
				+ android.os.Build.VERSION.SDK_INT + ","
				+ android.os.Build.VERSION.RELEASE;

		return result;
	}

}
