package com.jooyuu.qrlogin4game.bean;

import org.apache.http.NameValuePair;

public class PostParam implements NameValuePair {
	private String name;
	private String value;

	public PostParam(String name, String value) {
		this.name = name;
		this.value = value;
	}

	@Override
	public String getName() {
		return name;
	}

	@Override
	public String getValue() {
		return value;
	}

}
