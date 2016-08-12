package com.jooyuu.qrlogin4game;

import com.jooyuu.qrlogin4game.bean.LoginResult;

public interface ILoginResultCallback {

	public void handleLoginResult(LoginResult errResult);

}
