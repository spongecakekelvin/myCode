package com.voice.utils;

import android.util.Log;

public class HttpVoiceHelper {

	/**
	 * 多线程下载语音文件
	 * 
	 * @param strURL
	 * @param strFilePath
	 */
	public static void doGetVoice(final String strURL, final String strFilePath) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					//Log.e("jooyuu doGetVoice", "strURL="+strURL+",strFilePath="+strFilePath);
					HttpVoiceUtil.doGet(strURL, strFilePath);
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoiceGet("true");
				} catch (Exception e) {
					Log.e("jooyuu doGetVoice Exception", e.getMessage(), e);
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoiceGet("false");
				}
			}
		}).start();
	}

	/**
	 * 多线程上传语音文件
	 * 
	 * @param strURL
	 * @param strFilePath
	 */
	public static void doPutVoice(final String strURL, final String strFilePath) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					//Log.e("jooyuu doGetVoice", "strURL="+strURL+",strFilePath="+strFilePath);
					boolean isSuccess = HttpVoiceUtil.doPut(strURL, strFilePath);
					String strResult = isSuccess ? "true" : "false";
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoicePut(strResult);
				} catch (Exception e) {
					Log.e("jooyuu doPutVoice Exception", e.getMessage(), e);
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoicePut("false");
				}
			}
		}).start();
	}

}
