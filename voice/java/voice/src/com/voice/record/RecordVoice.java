package com.voice.record;
import java.io.File;
import java.io.IOException;

import com.voice.utils.VoiceManagement;

import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.util.Log;


public class RecordVoice {
	private static int mState = -1; // -1:没再录制，0：正在录音

	private static RecordVoice instance = null;

	private MediaPlayer mediaPlayer = null;
	
	
	private static void print(String string) {
		Log.i("RecordVoice", string);
	}
	
	public static RecordVoice getInstance(){
		if(instance == null){
			instance = new RecordVoice();
		}
		return instance;
	}

	/**
	 * 开始录音
	 */
	public void record(String path) {
		print("starting");
		if (mState != -1) {
			return;
		}
		int mResult = -1;
		MediaRecordFunc mRecord_2 = MediaRecordFunc.getInstance();
		mResult = mRecord_2.startRecordAndFile(path);

		if (mResult == RecordErrorCode.SUCCESS) {
			mState = 0;
		}
	}

	/**
	 * 停止录音
	 */
	public void stop() {
		print("stop!!");

		if (mState != -1) {
			MediaRecordFunc mRecord_2 = MediaRecordFunc.getInstance();
			mRecord_2.stopRecordAndFile();
			mState = -1;
		}
	}

	// 播放amr
	public void playAmr(final String path) {
		if (mediaPlayer == null) {
			mediaPlayer = new MediaPlayer();
		}

		if (mediaPlayer.isPlaying()) {
			mediaPlayer.stop();
			mediaPlayer.release();
			mediaPlayer = null;
			mediaPlayer = new MediaPlayer();
		}

		mediaPlayer
				.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
					@Override
					public void onCompletion(MediaPlayer mp) {
						Log.d("TEST", " playing amr  .onCompletion !!!");
						VoiceManagement.getInstance()
								.getVoiceCallBackListener().onPlayVoiceFinish();
						RecordVoice.this.mediaPlayer.release();
						RecordVoice.this.mediaPlayer = null;
					}
				});

		try {
			mediaPlayer.setDataSource(path);
			mediaPlayer.setOnPreparedListener(new OnPreparedListener() {
				@Override
				public void onPrepared(MediaPlayer mp) {
					mp.start();
				}
			});
			// Prepare to async playing
			mediaPlayer.prepareAsync();

		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

//		try {
//			mediaPlayer.prepare();
//		} catch (IllegalStateException e) {
//			e.printStackTrace();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}

		// mediaPlayer.start();
	}
	
	 /**
     * 获取文件大小
     * @param path,文件的绝对路径
     * @return
     */
    public long getFileSize(String path){
        File mFile = new File(path);
        if(!mFile.exists())
            return -1;
        return mFile.length();
    }


}