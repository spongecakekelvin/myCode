package com.jooyuu.qrlogin4game;

public interface ILoginHandler {

	public void onScanResult(String result);

	public void scanQrCode(int gameID, String accountName, String platformName, int serverID, String loginForwardUrl,
			String ext, String loginApiUrl, String signKey, ILoginResultCallback iLoginResultCallback);

}
