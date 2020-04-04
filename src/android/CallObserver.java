package cordova-plugin-twilio-video;

import org.json.JSONObject;

public interface CallObserver {
    void onEvent(String event, JSONObject data);
}