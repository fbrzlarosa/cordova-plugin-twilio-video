package cordova-plugin-twilio-video;

import org.apache.cordova.BuildHelper;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.LOG;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import org.json.JSONObject;


public class VideoConversationPlugin extends CordovaPlugin {

    public CallbackContext callbackContext;
    private CordovaInterface cordova;
    private String roomId;
    private String token;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        this.cordova = cordova;
        // your init code here
    }

    
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		this.callbackContext = callbackContext;
		if (action.equals("open")) {
            this.registerCallListener(callbackContext);
		    this.openRoom(args);
		}
        return true;
	}

	public void openRoom(final JSONArray args) {
        try {
            this.roomId = args.getString(0);
            this.token = args.getString(1);
            final CordovaPlugin that = this;
            final String token = this.token;
            final String roomId = this.roomId;

            LOG.d("TOKEN", token);
            LOG.d("ROOMID", roomId);
     		cordova.getThreadPool().execute(new Runnable() {
                public void run() {

                    Intent intentTwilioVideo = new Intent(that.cordova.getActivity().getBaseContext(), ConversationActivity.class);
        			intentTwilioVideo.putExtra("token", token);
                    intentTwilioVideo.putExtra("roomId", roomId);

                    that.cordova.startActivityForResult(that, intentTwilioVideo, 0);
                }
                    
            });
        } catch (JSONException e) {
            LOG.e("ROOM", "Invalid JSON string: ", e);
        }
    }

    public Bundle onSaveInstanceState() {
        Bundle state = new Bundle();
        state.putString("token", this.token);
        state.putString("roomId", this.roomId);
        return state;
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.token = state.getString("token");
        this.roomId = state.getString("roomId");
        this.callbackContext = callbackContext;
    }

    private void registerCallListener(final CallbackContext callbackContext) {
        if (callbackContext == null) {
            return;
        }
        CallEventsProducer.getInstance().setObserver(new CallObserver() {
            @Override
            public void onEvent(String event, JSONObject data) {
                LOG.i("EVENT", String.format("Event received: %s with data: %s", event, data));

                JSONObject eventData = new JSONObject();
                try {
                    eventData.putOpt("event", event);
                    eventData.putOpt("data", data);
                } catch (JSONException e) {
                    LOG.e("EVENT", "Failed to create event: " + event);
                    return;
                }

                PluginResult result = new PluginResult(PluginResult.Status.OK, eventData);
                result.setKeepCallback(true);
                callbackContext.sendPluginResult(result);
            }
        });
    }
}