package com.jooyuu.qrlogin4game.bean;

import com.jooyuu.qrlogin4game.ILoginResultCallback;

public class QrLoginInfo {
	private int gameID;
	private String accountName;
	private String platformName;
	private int serverID;
	private String loginForwardUrl;
	private String ext;

	private String loginApiUrl;
	private String signKey;
	private ILoginResultCallback loginResultCallback;

	public QrLoginInfo(int gameID, String accountName, String platformName, int serverID, String loginForwardUrl,
			String ext, String loginApiUrl, String signKey, ILoginResultCallback loginResultCallback) {
		super();
		this.gameID = gameID;
		this.accountName = accountName;
		this.platformName = platformName;
		this.serverID = serverID;
		this.loginForwardUrl = loginForwardUrl;
		this.ext = ext;
		this.loginApiUrl = loginApiUrl;
		this.signKey = signKey;
		this.loginResultCallback = loginResultCallback;
	}

	public int getGameID() {
		return gameID;
	}

	public String getAccountName() {
		return accountName;
	}

	public String getPlatformName() {
		return platformName;
	}

	public int getServerID() {
		return serverID;
	}

	public String getLoginForwardUrl() {
		return loginForwardUrl;
	}

	public String getExt() {
		return ext;
	}

	public String getLoginApiUrl() {
		return loginApiUrl;
	}

	public String getSignKey() {
		return signKey;
	}

	public ILoginResultCallback getLoginResultCallback() {
		return loginResultCallback;
	}

}
