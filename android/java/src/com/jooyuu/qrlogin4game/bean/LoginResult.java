package com.jooyuu.qrlogin4game.bean;

public class LoginResult {
	public int errCode;
	public String msg;

	public LoginResult(int errCode, String msg) {
		this.errCode = errCode;
		this.msg = msg;
	}

}
