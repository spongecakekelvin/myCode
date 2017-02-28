package com.example.getfacno;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.text.ClipboardManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends ActionBarActivity {
	
	private TextView text;
	public static Activity sContext = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		sContext = this;
		
		setContentView(R.layout.activity_main);
		text = (TextView) findViewById(R.id.facnoLabel);
		text.setText(getUniID());
		Button  cpButton = (Button) findViewById(R.id.copyButton);
		cpButton.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				switch (event.getAction()) {
				case MotionEvent.ACTION_CANCEL:
					break;
				case MotionEvent.ACTION_DOWN:
					break;
				case MotionEvent.ACTION_UP:
			        // 从API11开始android推荐使用android.content.ClipboardManager
			        // 为了兼容低版本我们这里使用旧版的android.text.ClipboardManager，虽然提示deprecated，但不影响使用。
			        ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
			        // 将文本内容放到系统剪贴板里。
			        cm.setText(text.getText());
			        Toast.makeText(sContext, "复制成功，可以发给朋友们了。", Toast.LENGTH_LONG).show();
					break;
				case MotionEvent.ACTION_MOVE:
					break;
				default:
					break;
				}
				return true;
			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	// ===========================================================
		// Inner and Anonymous Classes
		// ===========================================================
		public static String getUniID() {
			String m_szLongID = getDeviceInf();
			// String m_szLongID = m_szImei + m_szDevIDShort
			// + m_szAndroidID+ m_szWLANMAC + m_szBTMAC;
			// compute md5
			MessageDigest m = null;
			try {
				m = MessageDigest.getInstance("MD5");
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
			}
			m.update(m_szLongID.getBytes(), 0, m_szLongID.length());
			// get md5 bytes
			byte p_md5Data[] = m.digest();
			// create a hex string
			String m_szUniqueID = new String();
			for (int i = 0; i < p_md5Data.length; i++) {
				int b = (0xFF & p_md5Data[i]);
				// if it is a single digit, make sure it have 0 in front (proper
				// padding)
				if (b <= 0xF)
					m_szUniqueID += "0";
				// add number to string
				m_szUniqueID += Integer.toHexString(b);
			} // hex string to uppercase
			m_szUniqueID = m_szUniqueID.toUpperCase();
			return m_szUniqueID;
		}

		
		public static String getDeviceInf() {
			StringBuilder sb = new StringBuilder();
			sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
			sb.append("BOARD ").append(android.os.Build.BOARD).append("\n");
			sb.append("BOOTLOADER ").append(android.os.Build.BOOTLOADER)
					.append("\n");
			sb.append("BRAND ").append(android.os.Build.BRAND).append("\n");
			sb.append("CPU_ABI ").append(android.os.Build.CPU_ABI).append("\n");
			sb.append("CPU_ABI2 ").append(android.os.Build.CPU_ABI2).append("\n");
			sb.append("DEVICE ").append(android.os.Build.DEVICE).append("\n");
			sb.append("DISPLAY ").append(android.os.Build.DISPLAY).append("\n");
			sb.append("FINGERPRINT ").append(android.os.Build.FINGERPRINT)
					.append("\n");
			sb.append("HARDWARE ").append(android.os.Build.HARDWARE).append("\n");
			sb.append("HOST ").append(android.os.Build.HOST).append("\n");
			sb.append("ID ").append(android.os.Build.ID).append("\n");
			sb.append("MANUFACTURER ").append(android.os.Build.MANUFACTURER)
					.append("\n");
			sb.append("MODEL ").append(android.os.Build.MODEL).append("\n");
			sb.append("PRODUCT ").append(android.os.Build.PRODUCT).append("\n");
			sb.append("RADIO ").append(android.os.Build.RADIO).append("\n");
			sb.append("TAGS ").append(android.os.Build.TAGS).append("\n");
			sb.append("TIME ").append(android.os.Build.TIME).append("\n");
			sb.append("TYPE ").append(android.os.Build.TYPE).append("\n");
			sb.append("USER ").append(android.os.Build.USER).append("\n");

			String result = sb.toString() + "#####";

			result = result + android.os.Build.MODEL + ","
					+ android.os.Build.VERSION.SDK_INT + ","
					+ android.os.Build.VERSION.RELEASE;

			return result;
		}

}
