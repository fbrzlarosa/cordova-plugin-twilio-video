# cordova-plugin-twilio-video
Cordova Plugin for Twilio Video

## Methods

### open

Open connection:
```
window.TwilioVideo.openRoom = function(token, room, eventCallback, config) {
    config = config != null ? config : null;
    exec(function(e) {
        console.log("Twilio video event fired: " + e);
        if (eventCallback) {
            eventCallback(e.event, e.data);
        }
    }, null, 'TwilioVideoPlugin', 'openRoom', [token, room, config]);
};
```