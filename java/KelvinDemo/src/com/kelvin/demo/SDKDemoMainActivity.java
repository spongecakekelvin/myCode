package com.kelvin.demo;

import voice.VoiceUtil;
import android.app.Activity;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.TextView;

import com.kelvin.demo.NetBroadcastReceiver.netEventHandler;

public class SDKDemoMainActivity extends Activity implements netEventHandler {

	public static SDKDemoMainActivity instance;
	private String voiceId = "recordfile";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_sdkdemo_layout);

		instance = this;
		VoiceUtil.initVoiceListener(instance);
		Util.setContent(instance);

		initView();
	}

	private void initView() {
		Button loginBtn = (Button) findViewById(R.id.voiceSpeakBtn);
		loginBtn.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
//					VoiceUtil.startRecord(voiceId);
					break;
				case MotionEvent.ACTION_UP:
//					VoiceUtil.stopRecord();
					break;
				case MotionEvent.ACTION_MOVE:
					break;
				default:
					break;
				}
				return true;
			}
		});
		
		NetUtil.setContent(this);
		updateNetworkState();

		NetBroadcastReceiver.mListeners.add(this);
//		// wifi相关  
//		IntentFilter wifiIntentFilter;  // wifi监听器 // wifi  
//		wifiIntentFilter = new IntentFilter();  
//		wifiIntentFilter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
		Log.e(Global.TAG, "1111111111111111111");
		Util.getTelephoneInfo();

	}
	
	protected void updateNetworkState(){
		int state = NetUtil.getNetworkState(this);
		String stateName =  NetUtil.getNetworkStateName(state);
		int strength = 0;
		String str = "";
		if(state == NetUtil.NETWORN_WIFI){
			strength = NetUtil.getWifiStrength(this);
			str = stateName + "(" + strength + ")" + WifiManager.calculateSignalLevel(strength, 5);
		}else{
			strength = NetUtil.getStrength(this);
			str = stateName + "(" + strength + ")";
		}
		TextView stateText = (TextView) findViewById(R.id.stateText);
		stateText.setText(str);
//		Log.d(Global.TAG, "updateNetworkState , name(strength) =  "+ str);
	}


	// TODO GAME 游戏需要集成此方法并调用JyFusionSDK.getInstance().onRestart()
	@Override
	protected void onRestart() {
		super.onRestart();
	}

	// TODO GAME 游戏需要集成此方法并调用JyFusionSDK.getInstance().onResume()
	@Override
	protected void onResume() {
		super.onResume();
	}

	// TODO GAME 游戏需要集成此方法并调用JyFusionSDK.getInstance().onPause()
	@Override
	protected void onPause() {
		super.onPause();
	}

	// TODO GAME 游戏需要集成此方法并调用JyFusionSDK.getInstance().onStop()
	@Override
	protected void onStop() {
		super.onStop();
	}

	// TODO GAME 游戏需要集成此方法并调用JyFusionSDK.getInstance().onDestory()
	@Override
	protected void onDestroy() {
		super.onDestroy();
	}

	// TODO GAME
	// 在onActivityResult中需要调用JyFusionSDK.getInstance().onActivityResult
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
	}

	// TODO GAME 在onNewIntent中需要调用handleCallback将平台带来的数据交给JyFusionSDK处理
	@Override
	protected void onNewIntent(Intent intent) {
	}

	
	@Override
	public void onNetChange() {
		// TODO Auto-generated method stub
		updateNetworkState();
//		Log.d(Global.TAG, "onNetChange ===  ");
	}
	
	
}
