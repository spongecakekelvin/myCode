package voice;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.util.Log;

public class VoiceHttpRequest {

	private static VoiceHttpRequest instance;

	public static VoiceHttpRequest getInstance() {
		if (instance == null) {
			instance = new VoiceHttpRequest();
		}
		return instance;
	}

	private static String TAG = "Http Request";

	private String accessTokenUrl = "https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&"
			+ "client_id="
			+ "hlSR2WNGS9OIjG947FiqipK6&"
			+ "client_secret="
			+ "900317e03c5fd9edf1dbe6704a5dd9e7&";

	private String recognizeUrl = "http://vop.baidu.com/server_api";

	public String requestAccessToken() {
		String result = null;

		try {
			List<NameValuePair> postParameters = new ArrayList<NameValuePair>();
			// postParameters.add(new BasicNameValuePair("token", "alexzhou"));

			UrlEncodedFormEntity formEntity = new UrlEncodedFormEntity(
					postParameters);

			HttpPost httpPost = new HttpPost(accessTokenUrl);
			httpPost.setEntity(formEntity);

			HttpClient client = new DefaultHttpClient();
			HttpResponse response = client.execute(httpPost);

			// 成功返回
			// {
			// "access_token":
			// "1.a6b7dbd428f731035f771b8d15063f61.86400.1292922000-2346678-124328",
			// "expires_in": 86400,
			// "refresh_token":
			// "2.385d55f8615fdfd9edb7c4b5ebdc3e39.604800.1293440400-2346678-124328",
			// "scope": "public",
			// "session_key": "ANXxSNjwQDugf8615OnqeikRMu2bKaXCdlLxn",
			// "session_secret": "248APxvxjCZ0VEC43EYrvxqaK4oZExMB",
			// }

			// 失败返回
			// {
			// "error": "invalid_grant",
			// "error_description":
			// "Invalid authorization code: ANXxSNjwQDugOnqeikRMu2bKaXCdlLxn"
			// }

			// 检验状态码，如果成功接收数据
			int code = response.getStatusLine().getStatusCode();
//			Log.i(TAG, "code = " + code);

			if (code == HttpStatus.SC_OK) {
				String rev = EntityUtils.toString(response.getEntity());// 返回json格式：
																		// {"id":
																		// "27JpL~j4vsL0LX00E00005","version":
																		// "abc"}
				JSONObject obj = new JSONObject(rev);
				result = obj.getString("access_token");
//				Log.i(TAG, "result = " + result);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}

	// 隐示上传
	public String requestRecognizeHide(File file, long len) {
		String result = null;

		String accessToken = VoiceManagement.getInstance().getAccessToken();
		if (file == null || accessToken == null) {
			return result;
		}
		try {
			String imei = getPhoneIMEI();
			
	        HttpURLConnection conn = (HttpURLConnection) new URL(recognizeUrl
	                + "?cuid=" + imei + "&token=" + accessToken).openConnection();

	        // add request header
	        conn.setRequestMethod("POST");
	        conn.setRequestProperty("Content-Type", "audio/amr; rate=8000");

	        conn.setDoInput(true);
	        conn.setDoOutput(true);

	        // send request
	        DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
	        wr.write(loadFile(file));
	        wr.flush();
	        wr.close();

	        result = printResponse(conn);
			
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}


	public static String getPhoneIMEI() {
		Context context = VoiceManagement.getInstance().getActivity();
		String phoneIMEI = ((TelephonyManager) context
				.getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();

		return phoneIMEI;
	}
	
	
	private static String printResponse(HttpURLConnection conn) throws Exception {
		int code = conn.getResponseCode();
		Log.i(TAG, "code = " + code);
		
        if (code != 200) {
            // request error
            return "";
        }
        
        InputStream is = conn.getInputStream();
        BufferedReader rd = new BufferedReader(new InputStreamReader(is));
        String line;
        StringBuffer response = new StringBuffer();
        while ((line = rd.readLine()) != null) {
            response.append(line);
            response.append('\r');
        }
        rd.close();
        
        JSONObject resultObj = new JSONObject(response.toString());
        System.out.println(resultObj.toString(4));
        
        String result = "";
        
        int err_no = resultObj.getInt("err_no");
        
        
//		String err_msg = resultObj.getString("err_msg");
//		String sn = resultObj.getString("err_msg");
		
		if (err_no == 0) {
			if (resultObj.has("result")) {
	            JSONArray transitListArray = resultObj.getJSONArray("result");
//	            for (int i = 0; i < transitListArray.length(); i++) {
//	                System.out.print("Array:" + transitListArray.getString(i) + " ");
//	            }
	            result = transitListArray.getString(0);
//				result = resultObj.getString("result");
	        }
			
//			Log.i(TAG, "STR in json = " + result);
		}
		
//		Log.i(TAG, "sn = " + sn);
//		Log.i(TAG, "err_msg = " + err_msg);
//        Log.i(TAG, "response str = " + response.toString());
        
        return result;
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
            throw new IOException("Could not completely read file " + file.getName());
        }

        is.close();
        return bytes;
    }

}

