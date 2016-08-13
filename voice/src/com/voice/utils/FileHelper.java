package com.voice.utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import android.util.Base64;

public class FileHelper {

	/**
     * 文件转化为字节数组
  
     */
	
	public static File getFile(String path){
    	File file = new File(path);
    	if (file != null && file.exists()){
	    	return file;
    	}
    	return null;
    }
	
    public static byte[] getBytesFromFile(File f){
        if (f == null) {
            return null;
        }
        try {
            FileInputStream stream = new FileInputStream(f);
            ByteArrayOutputStream out = new ByteArrayOutputStream(1000);
            byte[] b = new byte[1000];
            int n;
            while ((n = stream.read(b)) != -1)
                out.write(b, 0, n);
            stream.close();
            out.close();
            return out.toByteArray();
        } catch (IOException e){
        }
        return null;
    }
    
    // 获取文件编码
    public static String getFileStr(String path){
    	String str = null;
    	File file = new File(path);
    	if (file != null && file.exists()){
	    	byte [] fileBytes = getBytesFromFile(file);
	    	str = new String(fileBytes);
    	}
    	return str;
    }
    
    // 获取文件base64编码
    public static String getFieleBase64Encode(String path){
    	File file = new File(path);
    	String encodeStr = null;
    	if (file != null && file.exists()){
    		byte [] encodeBytes = Base64.encode(getBytesFromFile(file), Base64.DEFAULT);  
    		encodeStr = new String(encodeBytes);
    	}
    	return encodeStr;
    }
    
}
