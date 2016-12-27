package voice;

public interface VoiceCallbackListener {
	public void onBeginOfSpeech();
	public void onEndOfSpeech();
	public void onResult(String resultStr);
	public void onVolumeChanged(float volumn);
	public void onError(String errStr);
	public void onPlayVoiceFinish();
	public void onRecordFinish();
	public void setAccessToken(String accessToken);
	public void onVoiceGet(String succ);
	public void onVoicePut(String succ);
//	public void setLuaWritePath(String path);
}
