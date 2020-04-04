package cordova-plugin-twilio-video;

import org.json.JSONObject;

public class CallEventsProducer {
    private CallObserver listener;
    private static CallEventsProducer instance;

    public static CallEventsProducer getInstance() {
        if (instance == null) {
            instance = new CallEventsProducer();
        }
        return instance;
    }

    public void setObserver(CallObserver listener) {
        this.listener = listener;
    }

    public void publishEvent(CallEvent event) {
        publishEvent(event, null);
    }

    public void publishEvent(CallEvent event, JSONObject data) {
        if (hasListener()) {
            listener.onEvent(event.name(), data);
        }
    }

    private boolean hasListener() {
        return listener != null;
    }
}