package com.jooyuu.sdk;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.util.Log;
import android.widget.Toast;

import com.jooyuu.fusionsdk.define.FusionErrType;
import com.jooyuu.fusionsdk.entity.LoginUserInfo;
import com.jooyuu.fusionsdk.listener.FsListener;
import com.jooyuu.fusionsdk.util.JyLog;

public class FusionSdkListener implements FsListener {
	private Cocos2dxActivity _activity;

	public FusionSdkListener(Activity activity) {
		_activity = (Cocos2dxActivity)activity;
	}

	@Override
	public void onInitSuccess() {
//		showTip("调用init函数成功,IMEI:" + FusionSdkUtils.getPhoneIMEI());
		Log.e("FUSION LOG", "onInitSuccess");
		callLuaFunc(_activity, "init_succ");
	}

	@Override
	public void onInitFailed(int type, int errCode, String errMsg) {
		showErrTip("调用Init函数失败", type, errCode, errMsg);
		callLuaFunc(_activity, "init_fail");
	}

	@Override
	public void onLoginSuccess(final String platformName, final LoginUserInfo loginUserInfo) {
//		showTip("调用login函数成功,platformName=" + platformName + "\r\n,LoginUserInfo=" + loginUserInfo.toString());
		_activity.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Log.e("FUSION LOG", "调用login函数成功,platformName=" + platformName + "\r\n,LoginUserInfo=" + loginUserInfo.toString());
				
				String token = loginUserInfo.getToken();
				String loginAccount = loginUserInfo.getLoginAccount();
				String platformToken = loginUserInfo.getPlatformUid();
				
//				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("SetLoginBtnState", "sucess");
				Cocos2dxActivity.callLuaGlobalFunction("javaCallLuaGlobalFun", "SetLoginBtnState");
				
				String paramStr = "##" + token + "|" + loginAccount + "|" + platformToken + "|" + platformName;
//				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("javaCallLuaGlobalFun", "login_succ"+paramStr);
				Cocos2dxActivity.callLuaGlobalFunction("javaCallLuaGlobalFun", "login_succ"+paramStr);
			}
		});
	}

	@Override
	public void onLoginFailed(String platformName, int type, int errCode, String errMsg) {
//			showErrTip("登录失败", type, errCode, errMsg);
			Log.e("FUSION LOG", "登录失败, type=" + type + ",errCode=" + errCode + ",errMsg=" + errMsg);
			callLuaFunc(_activity, "login_fail#" + type + "#" + errCode + "|" + errMsg);
	}

	@Override
	public void onLogoutSuccess() {
		callLuaFunc(_activity, "logout_succ");
	}

	@Override
	public void onLogoutFailed(int type, int errCode, String errMsg) {
		showErrTip("调用Logout函数失败", type, errCode, errMsg);
		callLuaFunc(_activity, "logout_fail");
	}

	@Override
	public void onPaySuccess() {
		// 订单支付成功
//		showTip("订单支付成功 ");
		callLuaFunc(_activity, "pay_succ");
	}

	@Override
	public void onPayFailed(int type, int errCode, String errMsg) {
//		showErrTip("订单支付失败 " + type +  errCode + errMsg);
		Log.e("FUSION LOG", "订单支付失败 " + type +  errCode + errMsg);
		callLuaFunc(_activity, "pay_fail#"+ type +  "#" + errCode +  "|" + errMsg);
	}

	@Override
	public void onExitSuccess() {
		callLuaFunc(_activity, "exit_succ");
		// 退出程序
		_activity.finish();
		System.exit(0);
	}

	@Override
	public void onExtendResult(int type, String msg) {
		String tip = "ExtendResult：type=" + type + ",msg=" + msg;
		showErrTip(tip);
	}

	/**************************************************************************************************
	 * 显示提示的额外函数
	 */
	private void showTip(String tip) {
		Toast.makeText(_activity, tip, Toast.LENGTH_SHORT).show();
	}

	private void showErrTip(String startTip, int type, int errCode, String errMsg) {
		String tip = startTip + "：" + "type=" + FusionErrType.getErrorDesc(type) + ",errCode=" + errCode + ",errMsg="
				+ errMsg;
		showErrTip(tip);
	}

	private void showErrTip(String tip) {
		JyLog.e(tip);

		if (_activity == null || _activity.isFinishing()) {
			return;
		} else {
			try {
				Toast.makeText(_activity, tip, Toast.LENGTH_SHORT).show();
			} catch (Exception e) {
				JyLog.e(e.getMessage(), e);
			}
		}
	}
	
	//  再GL 线程中调用lua函数
	public static void callLuaFunc(final Cocos2dxActivity activity, final String ret) {
		activity.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivity.callLuaGlobalFunction(
						"javaCallLuaGlobalFun", ret);
			}
		});
	}
}
