package com.jooyuu;

import java.io.File;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.util.Log;

import com.voice.record.RecordVoice;
import com.voice.utils.FileHelper;
import com.voice.utils.HttpVoiceHelper;
import com.voice.utils.VoiceHttpRequest;
import com.voice.utils.VoiceManagement;

public class GameUtil extends BaseGameUtil {
	private static final String TAG = "s3arpg";

	// 判断当前是否使用的是 WIFI网络
	public static int isWifiActive(int _para) {
		return BaseGameUtil.isWifiActive(_para, Cocos2dxActivity.getContext());
	}

	public static void openUrl(String url) {
		BaseGameUtil.openUrl(url, Cocos2dxActivity.getContext());
	}

	public static void autoInstall(String path) {
		BaseGameUtil.autoInstall(path, Cocos2dxActivity.getContext());
	}

	/**
	 * 米大师的充值接口
	 */
	public static void midasPayMent(String zone_id, String goods_token_url) {
//		AppActivity.midasPayMent(zone_id, goods_token_url);
	}

	/**
	 * 百度语音听写
	 */

	// 播放amr文件
	public static void playVoice(String path) {
		// String path = VoiceManagement.getInstance().getVoicePath(voiceId);
		Log.d(TAG, " playing voice...=" + path);
		File file = FileHelper.getFile(path);
		if (file == null) {
			Log.d(TAG, "play voice 找不到文件路径 =" + path);
		}
		RecordVoice.getInstance().playAmr(path);
	}

	public static void setVoicePath(String writePath) {
		// Log.d(TAG, " set writePath ...." + writePath);
		// VoiceManagement.getInstance().setWritePath(writePath);
	}

	// 重命名文件
	public static void renameFile(String oldPath, String newPath) {
		// oldPath = VoiceManagement.getInstance().getVoicePath(oldPath);
		// newPath = VoiceManagement.getInstance().getVoicePath(newPath);

		File file = new File(oldPath);
		boolean isSucc = file.renameTo(new File(newPath));
		if (isSucc == true) {
			Log.i("GameUtil", "重命名" + oldPath + "为" + newPath + "成功");
		} else {
			Log.i("GameUtil", "重命名" + oldPath + "为" + newPath + "失败");
		}
	}

	public static void deleteFile(String path) {
		// path = VoiceManagement.getInstance().getVoicePath(path);

		File file = new File(path);
		// File file = new
		// File(VoiceManagement.getInstance().getVoiceDirPath());
		if (file != null && file.exists()) {
			Log.i("GameUtil", "删除" + path + "成功");
			file.delete();
		} else {
			Log.i("GameUtil", "删除" + path + "成功");
		}
	}

	/**
	 * 开始录音
	 */
	public static void startRecord(String path) {
		// String path = VoiceManagement.getInstance().getVoicePath(voiceId);
		Log.d(TAG, " record voice start path = " + path);
		RecordVoice.getInstance().record(path);
	}

	public static void stopRecord() {
		Log.d(TAG, " record voice stop");
		RecordVoice.getInstance().stop();
	}

	// 开始录制
	public static void startBaiduRecognize(String path) {
		// 暂时直返回成功
		// String path = VoiceManagement.getInstance().getVoicePath(voiceId);
		File file = FileHelper.getFile(path);
		long len = RecordVoice.getInstance().getFileSize(path);

		if (file != null) {
			Log.d(TAG, "获取文件成功");
			// 另开线程运行
			Cocos2dxActivity.requestRecognize(file, len);

		} else {
			Log.d(TAG, "获取文件失败!");
		}

	}

	// 客户端请求accessToken
	public static void requestAccessToken() {
		String accessToken = VoiceHttpRequest.getInstance().requestAccessToken();
		if (accessToken != null) {
			Log.d(TAG, "客户端请求的 accessToken为  " + accessToken);
			VoiceManagement.getInstance().setAccessToken(accessToken);

			// 传给lua
			VoiceManagement.getInstance().getVoiceCallBackListener().setAccessToken(accessToken);
		}
	}

	// lua中传入
	public static void setAccessToken(String accessToken) {

		VoiceManagement.getInstance().setAccessToken(accessToken);
	}

	public static void doGetVoice(String url, String filename) {
		Log.d(TAG, "下载文件.11...!" + filename);
		// filename = VoiceManagement.getInstance().getVoicePath(filename);
		// Log.d(TAG, "下载文件.22...!" + filename);
		HttpVoiceHelper.doGetVoice(url, filename);
	}

	public static void doPutVoice(String url, String filename) {
		Log.d(TAG, "上传文件....!");
		HttpVoiceHelper.doPutVoice(url, filename);
	}

}
