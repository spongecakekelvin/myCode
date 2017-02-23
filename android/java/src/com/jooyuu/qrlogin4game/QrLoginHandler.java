package com.jooyuu.qrlogin4game;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.jooyuu.qrlogin4game.bean.LoginResult;
import com.jooyuu.qrlogin4game.bean.PostParam;
import com.jooyuu.qrlogin4game.bean.QrLoginInfo;
import com.jooyuu.qrlogin4game.zxing.CaptureActivity;

public class QrLoginHandler implements ILoginHandler {

	private Activity appActivity;
	private int scanCode;
	private QrLoginInfo qrLoginInfo;

	public QrLoginHandler(Activity instance, int scanCode) {
		this.appActivity = instance;
		this.scanCode = scanCode;
	}

	public void scanQrCode(int gameID, String accountName, String platformName, int serverID, String loginForwardUrl,
			String ext, String loginApiUrl, String signKey, ILoginResultCallback loginResultCallback) {
		qrLoginInfo = new QrLoginInfo(gameID, accountName, platformName, serverID, loginForwardUrl, ext, loginApiUrl,
				signKey, loginResultCallback);
		Intent intent = new Intent(this.appActivity, CaptureActivity.class);
		appActivity.startActivityForResult(intent, scanCode);
	}

	// 处理扫描结果的逻辑
	public void onScanResult(final String resultData) {
		new Thread() {
			@Override
			public void run() {
				// 把网络访问的代码放在这里
				loginAccountToWebGame(resultData);
			}
		}.start();
	}

	/**
	 * 请求登录到网页游戏
	 * 
	 * @param qrCode
	 * @param gameID
	 * @param accountName
	 * @param platformName
	 * @param serverID
	 * @param loginUrl
	 * @param object
	 */
	private void loginAccountToWebGame(String qrCode) {
		Log.e("jooyuu", "loginAccountToWebGame");
		LoginResultHandler resultHandler = new LoginResultHandler( this.appActivity, qrLoginInfo);

		// 对验证码进行基础校验
		if (qrCode == null || qrCode.length() < 1 || !qrCode.startsWith("qrlogin")) {
			resultHandler.sendLoginResult(new LoginResult(-1, "亲，这不是合法的登录游戏二维码"));
			return;
		}

		String signKey = qrLoginInfo.getSignKey();
		String qrLoginApiServerUrl = qrLoginInfo.getLoginApiUrl();
		// 其他前端传递过来的参数
		int gameID = qrLoginInfo.getGameID();
		String accountName = qrLoginInfo.getAccountName();
		String platformName = qrLoginInfo.getPlatformName();
		int serverID = qrLoginInfo.getServerID();
		String loginUrl = qrLoginInfo.getLoginForwardUrl();
		String ext = qrLoginInfo.getExt();

		try {
			List<NameValuePair> postParameters = new ArrayList<NameValuePair>();
			postParameters.add(new PostParam("qrcode", qrCode));
			postParameters.add(new PostParam("game_id", String.valueOf(gameID)));
			postParameters.add(new PostParam("account_name", accountName));
			postParameters.add(new PostParam("platform_name", platformName));
			postParameters.add(new PostParam("server_id", String.valueOf(serverID)));
			postParameters.add(new PostParam("login_url", loginUrl));
			postParameters.add(new PostParam("ext", ext));

			// 额外的校验字段
			Date today = new java.util.Date();
			String loginTime = String.valueOf(today.getTime() / 1000);
			StringBuilder sbSource = new StringBuilder();
			sbSource.append(qrCode);
			sbSource.append(loginUrl);
			sbSource.append(loginTime);
			sbSource.append(signKey);
			String sign = stringToMD5(sbSource.toString());
			postParameters.add(new PostParam("login_time", String.valueOf(loginTime)));
			postParameters.add(new PostParam("ver", "1.0"));
			postParameters.add(new PostParam("sign", sign));

			UrlEncodedFormEntity formEntity = new UrlEncodedFormEntity(postParameters);

			HttpPost httpPost = new HttpPost(qrLoginApiServerUrl);
			httpPost.setEntity(formEntity);

			HttpClient client = new DefaultHttpClient();
			HttpResponse response = client.execute(httpPost);

			// 检验状态码，如果成功接收数据
			int code = response.getStatusLine().getStatusCode();

			Log.e("jooyuu", "code=" + code);
			if (code == HttpStatus.SC_OK) {

				String rev = EntityUtils.toString(response.getEntity());// 返回json格式
				JSONObject obj = new JSONObject(rev);
				int errCode = obj.getInt("code");
				String msg = obj.getString("msg");
				resultHandler.sendLoginResult(new LoginResult(errCode, msg));
			} else {
				resultHandler.sendLoginResult(new LoginResult(-2, "网络状态异常,HttpStatuscode=" + code));
			}
		} catch (Exception e) {
			e.printStackTrace();
			resultHandler.sendLoginResult(new LoginResult(-3, "系统错误,getMessage=" + e.getMessage()));
		}

	}

	// 小写的MD5算法
	@SuppressLint("DefaultLocale")
	public static String stringToMD5(String strSource) throws NoSuchAlgorithmException, UnsupportedEncodingException {
		byte[] hash;

		hash = MessageDigest.getInstance("MD5").digest(strSource.getBytes("UTF-8"));
		StringBuilder hex = new StringBuilder(hash.length * 2);
		for (byte b : hash) {
			if ((b & 0xFF) < 0x10)
				hex.append("0");
			hex.append(Integer.toHexString(b & 0xFF));
		}

		return hex.toString();
	}

}
