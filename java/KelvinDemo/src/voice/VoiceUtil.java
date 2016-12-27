package voice;

import java.io.File;

import android.app.Activity;
import android.util.Log;
import android.widget.Toast;


public class VoiceUtil {
	
	public static Activity s_oActivityInstance = null;
	
	public static String TAG = "voice test";
	
	/**
	 * 开始录音
	 */
	public static void startRecord(String voiceId) {
		String path = VoiceManagement.getInstance().getVoicePath(voiceId);
		// Log.d(TAG, " record voice start path = " + path);
		RecordVoice.getInstance().record(path);
	}

	public static void stopRecord() {
		RecordVoice.getInstance().stop();
	}
	
	public static void callLuaFunc(final Activity activity, final String ret, final String code) {
		Toast.makeText(activity, ret + code, Toast.LENGTH_SHORT).show();
//		lua接口的调用需要在GL线程中执行
//		public static void callLuaFunc(final AppActivity activity, final String ret) {
//		activity.runOnUiThread(new Runnable() {
//			@Override
//			public void run() {
//				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
//						"javaCallLuaGlobalFun", ret);
//			}
//		});
	}
	
	
	/**
	 * 开始录制
	 */
	public static void startBaiduRecognize(String voiceId) {
		// 暂时直返回成功
		String path = VoiceManagement.getInstance().getVoicePath(voiceId);
		File file = FileHelper.getFile(path);
		long len = RecordVoice.getInstance().getFileSize(path);

		if (file != null) {
			// Log.d(TAG, "获取文件成功");
			// 另开线程运行
			requestRecognize(file, len);
		} else {
			Log.e(TAG, "获取文件失败!");
		}

	}
	
	private static void requestRecognize(final File file, final long len) {
//		s_oActivityInstance.runOnUiThread(new Runnable() {
//			@Override
//			public void run() {
				String resultStr = VoiceHttpRequest.getInstance().requestRecognizeHide(file, len);
				Log.i(TAG, "识别结果  = " + resultStr);
				VoiceManagement.getInstance().getVoiceCallBackListener().onResult(resultStr);
//			}
//		});

	}
	
	/**
	 * 语音听写
	 * 
	 * @author YuZhenjian
	 */
	public static void initVoiceListener(final Activity s_oActivityInstance) {
		// 语音识别
		VoiceManagement.getInstance().setActivity(s_oActivityInstance);

		// 监听回调
		VoiceManagement.getInstance().setVoiceCallBackListener(new VoiceCallbackListener() {
			public void onBeginOfSpeech() {
				callLuaFunc(s_oActivityInstance, "onVoiceBeginOfSpeech", "");
			}

			public void onEndOfSpeech() {
				callLuaFunc(s_oActivityInstance, "onVoiceEndOfSpeech", "");
			}

			public void onResult(final String resultStr) {
				// Log.i("appActivity", "onResult~~~~~~~~~~~~~~~~~~");
				callLuaFunc(s_oActivityInstance, "onVoiceResult", resultStr);
			}

			public void onVolumeChanged(final float volumn) {
				callLuaFunc(s_oActivityInstance, "onVoiceVolumeChanged", "" + volumn);
			}

			public void onError(final String errStr) {
				callLuaFunc(s_oActivityInstance, "onVoiceError", errStr);
			}

			public void onPlayVoiceFinish() {
				callLuaFunc(s_oActivityInstance, "onPlayVoiceFinish", "");
			}

			public void onRecordFinish() {
				callLuaFunc(s_oActivityInstance, "onPlayVoiceFinish", "");
			}

			// 客户端请求accessToken时 用
			public void setAccessToken(final String accessToken) {
				callLuaFunc(s_oActivityInstance, "setAccessToken", accessToken);
			}

			// 上传返回
			public void onVoicePut(final String succ) {
				callLuaFunc(s_oActivityInstance, "onVoicePut", succ);
			}

			// 下载返回
			public void onVoiceGet(final String succ) {
				callLuaFunc(s_oActivityInstance, "onVoiceGet", succ);
			}

		});
	}
	
}