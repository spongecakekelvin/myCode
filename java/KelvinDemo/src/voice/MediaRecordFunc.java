package voice;

import java.io.File;
import java.io.IOException;



import android.media.MediaRecorder;
import android.util.Log;

public class MediaRecordFunc {
	  private boolean isRecord = false;
	  private static final String TAG = "Recod func";
	   
	  private MediaRecorder mMediaRecorder;
	  private MediaRecordFunc(){
	  }
	   
	  private static MediaRecordFunc mInstance;
	  public synchronized static MediaRecordFunc getInstance(){
	    if(mInstance == null)
	      mInstance = new MediaRecordFunc();
	    return mInstance;
	  }
	   
	  public int startRecordAndFile(String path){
	  Log.i(TAG, "startRecordAndFile....");
//	    if(AudioFileFunc.isSdcardExit())
//	    {
	      if(isRecord)
	      {
	        return RecordErrorCode.E_STATE_RECODING;
	      }
	      else
	      {
	        if(mMediaRecorder == null)
	          createMediaRecord(path);
	         
	        try{
	          mMediaRecorder.prepare();
	          mMediaRecorder.start();
	          // 让录制状态为true  
	          isRecord = true;
	          return RecordErrorCode.SUCCESS;
	        }catch(IOException ex){
	          ex.printStackTrace();
	          return RecordErrorCode.E_UNKOWN;
	        }
	      }
//	    }     
//	    else
//	    {
//	      return ErrorCode.E_NOSDCARD;        
//	    }     
	  }
	   
	   
	  public void stopRecordAndFile(){
	     close();
	  }
	   
	   
	  private void createMediaRecord(String path){
		  Log.i(TAG, "createMediaRecord....");  
		  
	     /* ①Initial：实例化MediaRecorder对象 */
	    mMediaRecorder = new MediaRecorder();
	     
	    /* setAudioSource/setVedioSource*/
	    mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);//设置麦克风
	     
	    /* 设置输出文件的格式：THREE_GPP/MPEG-4/RAW_AMR/Default
	     * THREE_GPP(3gp格式，H263视频/ARM音频编码)、MPEG-4、RAW_AMR(只支持音频且音频编码要求为AMR_NB)
	     */
	     mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
	      
	     /* 设置音频文件的编码：AAC/AMR_NB/AMR_MB/Default */
	     mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
	      
	     /* 设置输出文件的路径 */
	     File file = new File(path);
	     if (file.exists()) {  
	       file.delete();  
	     } 
	     mMediaRecorder.setOutputFile(path);
	  }
	   
	  
	   
	  private void close(){
	    if (mMediaRecorder != null) {  
	      Log.i(TAG, "stopRecord....");  
	      isRecord = false;
	      mMediaRecorder.stop();  
	      mMediaRecorder.release();  
	      mMediaRecorder = null;
	    }  
	  }
}