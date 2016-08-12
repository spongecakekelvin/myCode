package com.jooyuu.qrlogin4game;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;

import com.jooyuu.qrlogin4game.bean.LoginResult;
import com.jooyuu.qrlogin4game.bean.QrLoginInfo;

public class LoginResultHandler {

	private Handler handler;
	private QrLoginInfo qrLoginInfo;

	public LoginResultHandler(Activity appActivity, QrLoginInfo qrLoginInfo) {
		this.qrLoginInfo = qrLoginInfo;
		this.handler = new Handler(appActivity.getMainLooper()) {

			@Override
			public void handleMessage(Message msg) {
				super.handleMessage(msg);
				if (msg.what == 1) {
					handleCallbackMessage((LoginResult) msg.obj);
				}
			}

		};
	}

	/**
	 * 对登录结果的处理
	 * 
	 * @param errResult
	 */
	public void handleCallbackMessage(LoginResult errResult) {
		ILoginResultCallback resultCallback = qrLoginInfo.getLoginResultCallback();
		resultCallback.handleLoginResult(errResult);
	}

	public void sendLoginResult(LoginResult result) {
		Message message = new Message();
		message.what = 1;
		message.obj = result;
		handler.sendMessage(message);
	}

}
