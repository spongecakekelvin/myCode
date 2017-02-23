package com.jooyuu.sdk;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Handler;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.jooyuu.fusionsdk.FusionSDK;
import com.jooyuu.fusionsdk.entity.FsInitParams;
import com.jooyuu.fusionsdk.entity.FsPayParams;
import com.jooyuu.fusionsdk.entity.GameRoleInfo;
import com.jooyuu.fusionsdk.util.JyLog;

public class FusionSdkUtils {
	private static Activity _activity = null;
	private static Handler mHandler = null;

	public static String getVersion() {
		return "1.2.0";
	}

	/**
	 * 需要第一个调用的初始化函数
	 */
	public static void initCreate(Activity appActivity) {
		_activity = appActivity;
		mHandler = new Handler( _activity.getMainLooper());
	}
	
	public static void initSDK(final String platformName) {
		try {
			// 配置JySDK登录所需的数据
			FsInitParams initParams = new FsInitParams();
			initParams.channel_tag = checkChannelTag(platformName); 
			doInitSDK(initParams);
		} catch (Exception e) {
			JyLog.e(e.getMessage(), e);
		}
	}

	private static String checkChannelTag(String platformName){
		String channel_tag = Cocos2dxActivity.getChannelID("fuckverymuch");
		if (channel_tag == null || channel_tag == ""){
			Log.e("FusionSdkutils",  "(2) get channel tag ");
			channel_tag = platformName;
		}
		JyLog.d(" initParams.channel_tag = " + channel_tag);
		return channel_tag;
	}

//	public static void initSDK() {
//		try {
//			// 配置JySDK登录所需的数据
//			FsInitParams initParams = new FsInitParams();
//			initParams.channel_tag = "jooyuu_uc_shenzuo";
//			initParams.networkErrorReconnectType = JyConstanst.API_NERWORK_ERR_RECONN_ONLYOK;
//			initParams.isShowRetryMidas = false; // 是否在拉起腾讯充值时显示重试按钮，默认不显示
//
//			doInitSDK(initParams);
//		} catch (Exception e) {
//			JyLog.e(e.getMessage(), e);
//		}
//	}

	public static void login(String strJsonArgs) {
		try {
			JSONObject jsArgs = new JSONObject(strJsonArgs);
			String platformName = jsArgs.optString("platform_name");
			doLogin(platformName);
		} catch (Exception e) {
			JyLog.e(e.getMessage(), e);
		}
	}

	public static void logout(String strJsonArgs) {
		try {
			doLogout();
		} catch (Exception e) {
			JyLog.e(e.getMessage(), e);
		}
	}

	public static void pay(String strJsonArgs) {
		pay(_activity, strJsonArgs);
	}

	public static void pay(Activity activity, String strJsonArgs) {
		try {
			JSONObject jsArgs = new JSONObject(strJsonArgs);
			Log.e("FUSION LOG", "strJsonArgs = " + strJsonArgs);
			
			FsPayParams payParams = new FsPayParams();
			payParams.setPayMoney(jsArgs.optDouble("pay_money"));
			payParams.setGoodsName(jsArgs.optString("goods_name"));
			payParams.setGoodsDesc(jsArgs.optString("goods_desc"));
			payParams.setGoodsId("1");
			payParams.setCpNotifyUrl(jsArgs.optString("cp_notify_url"));
			payParams.setCpOrderId(jsArgs.optString("cp_order_id"));
			// 下面是可选参数
			payParams.setCpExt(jsArgs.optString("cp_ext")); // 游戏开发商提供的扩展字段，透传数据
			payParams.setExchangeGoldRate(jsArgs.optInt("exchange_gold_rate")); // 人民币跟游戏币的兑换比例，默认是10
			payParams.setPayType(jsArgs.optInt("pay_type")); // 充值类型，如果不传递或者=0则采用服务端控制 1甲游自己的支付  2YSDK支付
			payParams.setIsSandbox(jsArgs.optInt("is_sandbox")); // 是否开启测试模式，1为开启 0为否
						
			GameRoleInfo roleInfo = new GameRoleInfo();
			roleInfo.setRoleID(jsArgs.optString("role_id"));
			roleInfo.setRoleName(jsArgs.optString("role_name"));
			roleInfo.setRoleLevel(jsArgs.optInt("role_level"));
			roleInfo.setServerID(jsArgs.optInt("server_id"));
			roleInfo.setServerName("S" + jsArgs.optInt("server_id"));
			roleInfo.setVipLevel(jsArgs.optInt("vip_level"));
			roleInfo.setFamilyName("");
			roleInfo.setCoinNum("0");

			doPay(activity, payParams, roleInfo);
		} catch (Exception e) {
			JyLog.e(e.getMessage(), e);
		}
	}

	// 退出游戏
	public static boolean exitSDK() {
		try {
			if (FusionSDK.getInstance().isShowExitDialog()) {
				FusionSDK.getInstance().exit(_activity);
				return true;
			}
		} catch (Exception e) {
			JyLog.e(e.getMessage(), e);
		}
		return false;
	}

	public static void submitGameRoleInfo(String strJsonArgs) {
		try {
			JSONObject jsArgs = new JSONObject(strJsonArgs);
			GameRoleInfo roleInfo = new GameRoleInfo();
			
			roleInfo.setCoinNum(jsArgs.optString("coin_num"));
			roleInfo.setCreateRoleTime(jsArgs.optLong("create_role_time"));
			roleInfo.setDataType(jsArgs.optInt("data_type"));
			roleInfo.setExtras(jsArgs.optString("extras"));
			roleInfo.setFamilyName(jsArgs.optString("family_name"));
			roleInfo.setGameName(jsArgs.optString("game_name"));
			roleInfo.setLevelupTime(jsArgs.optLong("level_up_time"));
			roleInfo.setRoleCategory(jsArgs.optString("role_category"));
			roleInfo.setRoleID(jsArgs.optString("role_id"));
			roleInfo.setRoleLevel(jsArgs.optInt("role_level"));
			roleInfo.setRoleName(jsArgs.optString("role_name"));
			roleInfo.setServerID(jsArgs.optInt("server_id"));
			roleInfo.setServerName(jsArgs.optString("server_name"));
//			roleInfo.setServerName("S" + jsArgs.optInt("server_id"));
			roleInfo.setVipLevel(jsArgs.optInt("vip_level"));
			
			doSubmitGameRoleInfo(roleInfo);
		} catch (Exception e) {
			JyLog.e(e.getMessage(), e);
		}
	}

	public static void showFloatView(final String strJsonArgs) {
//		_activity.runOnUiThread(new Runnable() {
////		Thread sendThread=new Thread(new Runnable(){ 
		mHandler.post(new Runnable() {
			@Override
			public void run() {
				try {
					JSONObject jsArgs = new JSONObject(strJsonArgs);
					String strIsShow = jsArgs.optString("is_show");
					doShowFloatView(Boolean.parseBoolean(strIsShow));
				} catch (Exception e) {
					JyLog.e(e.getMessage(), e);
				}
			}
		});
	}

	/**
	 * 几个扩展函数
	 */
	public static String isSupportMethod(String strJsonArgs) {
		return "false";
	}

	public static String callFunction(String funcName, String strJsonArgs) {
		return "";
	}

	public static String getExtrasConfig(String strJsonArgs) {
		return "";
	}

	// ////////////////////////////////////////////////////////////////
	// //
	// //内部函数实现
	// //
	// ///////////////////////////////////////////////////////////////

	private static void doInitSDK(FsInitParams initParams) {
		// 初始化FusionSDK
		FusionSDK.getInstance().init(_activity, initParams, new FusionSdkListener(_activity));
//		FusionSDK.getInstance().setLoginDialog(_activity, true, Color.argb(127, 127, 127, 127));
	}

	private static void doLogin(String platformName) {
		FusionSDK.getInstance().login(_activity, platformName);
	}

	private static void doLogout() {
		FusionSDK.getInstance().logout(_activity);
	}

	private static void doPay(Activity activity, FsPayParams payParams, GameRoleInfo roleInfo) {
		FusionSDK.getInstance().pay(activity, payParams, roleInfo);
	}

	private static void doSubmitGameRoleInfo(GameRoleInfo roleInfo) {
		FusionSDK.getInstance().submitGameRoleInfo(_activity, roleInfo);
	}

	private static void doShowFloatView(boolean isShow) {
		FusionSDK.getInstance().showFloatView(_activity, isShow);
	}

	public static String getPhoneIMEI() {
		try {
			return getPhoneIMEI(_activity);
		} catch (Exception e) {
			return "";
		}
	}

	/**
	 * 获取SIM卡IEMI
	 * 
	 * @param context
	 * @return
	 */
	private static String getPhoneIMEI(Context context) {
		String phoneIMEI = ((TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();
		return phoneIMEI;
	}

}
