package com.voice.utils;

import android.app.Activity;
import android.os.Environment;

public class VoiceManagement {
	
	private static VoiceManagement voiceManagement;
	
	private String voiceId = "0";
	
	private String accessToken = ""; // 开发者身份验证密钥
	
	private String writePath = Environment.getExternalStorageDirectory().getPath() + "/voice/"; //默认值， 实际 从lua传过来
	
	
	public Activity activityInstance = null;
	
	private VoiceCallbackListener voiceCallbackListener = null;

	public static VoiceManagement getInstance(){
		if(voiceManagement == null){
			voiceManagement = new VoiceManagement();
		}
		return voiceManagement;
	}

	
	public void setActivity(Activity activity){
		activityInstance = activity;
	}
	
	public Activity getActivity(){
		return activityInstance;
	}
	
	public void setVoiceCallBackListener(VoiceCallbackListener voiceCallbackListener){
		this.voiceCallbackListener = voiceCallbackListener;
	}
	
	public VoiceCallbackListener getVoiceCallBackListener(){
		return this.voiceCallbackListener;
	}
	
	
	public void setCurrentVoiceId(String voiceId){
		this.voiceId = voiceId;
	}
	
	public String getCurrentVoiceId(){
		return this.voiceId;
	}
	
	
	// 获取录音文件路径
	public String getVoicePath(){
		return getVoicePath(this.voiceId);
	}
	
	public String getVoicePath(String voiceName){
		String  filePath = getVoiceDirPath() + voiceName + ".amr"; //因为改后缀还要改PlayVoice代码, 所以后缀名写死在这里了
		return filePath;
	}
	

	public void setWritePath(String writePath){
//		this.writePath = writePath;
//		VoiceManagement.getInstance().getVoiceCallBackListener().setLuaWritePath(this.writePath);
	}
	
	// 取得录音文件的 目录
	public String getVoiceDirPath(){
		return this.writePath;
	}
	
	
	 // 开发者身份验证密钥
	public void setAccessToken(String accessToken){
		this.accessToken = accessToken;
	}
	
	public String getAccessToken(){
		return this.accessToken;
	}
	
	
}
