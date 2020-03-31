# cordova-plugin-twilio-video
Cordova Plugin for Twilio Video

## Methods

### open

Open connection:
```
cordova.videoconversation.open($parameters.RoomName,$parameters.AccessToken, function(e){
    alert(e.event);
    if( e!== undefined && e!== null && ( ( typeof e !== object && e.toUpperCase() === "PARTICIPANT_DISCONNECTED" ) || ( typeof e === object && e.event === "PARTICIPANT_DISCONNECTED" ) ) ) {
        alert('Twilio Participant Disconnect fired');
    }
}, function(error) {
    alert(error);
});
```