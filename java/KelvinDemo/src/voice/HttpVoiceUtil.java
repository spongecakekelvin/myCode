package voice;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import android.util.Log;

public class HttpVoiceUtil {

	private static final String METHOD_GET = "GET";
	private static final String METHOD_PUT = "PUT";

	/**
	 * 下载指定路径的文件，并写磁盘
	 */
	public static void doGet(String strUrl, String filePath) throws Exception {
		URL url = new URL(strUrl);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod(METHOD_GET);
		conn.setConnectTimeout(10 * 1000);
		conn.setReadTimeout(10 * 1000);

		conn.connect();
		// 创建目录
		mkFileDir(filePath);

		InputStream is = conn.getInputStream();
		FileOutputStream fos = new FileOutputStream(filePath);
		byte[] b = new byte[2048];
		int size=0;
		//保存文件  
        while ((size = is.read(b)) != -1)  
            fos.write(b, 0, size);  
        
		is.close();
		fos.close();

		conn.disconnect();
	}

	private static void mkFileDir(String filePath) {
		File file = new File(filePath);
		if (!file.exists()) {
			if (!file.getParentFile().exists()) {
				file.getParentFile().mkdirs();
			}
		}
	}

	/**
	 * 读取，并上传指定文件
	 */
	public static boolean doPut(String strUrl, String filePath)
			throws Exception {
		URL url = new URL(strUrl);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod(METHOD_PUT);
		conn.setConnectTimeout(10 * 1000);
		conn.setDoInput(true);
		conn.setDoOutput(true);
		// send request
		DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
		File pcmFile = new File(filePath);
		wr.write(loadFile(pcmFile));
		wr.flush();
		wr.close();

		boolean isSuccess = conn.getResponseCode() == 200;
		conn.disconnect();
		return isSuccess;
	}
 

	private static byte[] loadFile(File file) throws IOException {
		InputStream is = new FileInputStream(file);

		long length = file.length();
		byte[] bytes = new byte[(int) length];

		int offset = 0;
		int numRead = 0;
		while (offset < bytes.length
				&& (numRead = is.read(bytes, offset, bytes.length - offset)) >= 0) {
			offset += numRead;
		}

		if (offset < bytes.length) {
			is.close();
			throw new IOException("Could not completely read file "
					+ file.getName());
		}

		is.close();
		return bytes;
	}
	
	/**
	 * 多线程下载语音文件
	 * 
	 * @param strURL
	 * @param strFilePath
	 */
	public static void doGetVoice(final String strURL, final String strFilePath) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					//Log.e("jooyuu doGetVoice", "strURL="+strURL+",strFilePath="+strFilePath);
					HttpVoiceUtil.doGet(strURL, strFilePath);
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoiceGet("true");
				} catch (Exception e) {
					Log.e("jooyuu doGetVoice Exception", e.getMessage(), e);
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoiceGet("false");
				}
			}
		}).start();
	}

	/**
	 * 多线程上传语音文件
	 * 
	 * @param strURL
	 * @param strFilePath
	 */
	public static void doPutVoice(final String strURL, final String strFilePath) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					//Log.e("jooyuu doGetVoice", "strURL="+strURL+",strFilePath="+strFilePath);
					boolean isSuccess = HttpVoiceUtil.doPut(strURL, strFilePath);
					String strResult = isSuccess ? "true" : "false";
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoicePut(strResult);
				} catch (Exception e) {
					Log.e("jooyuu doPutVoice Exception", e.getMessage(), e);
					VoiceManagement.getInstance().getVoiceCallBackListener().onVoicePut("false");
				}
			}
		}).start();
	}

}
