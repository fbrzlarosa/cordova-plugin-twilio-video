//
//  TwilioVideoViewController.m
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

@import TwilioVideo;
#import "TwilioVideoViewController.h"
#import <Foundation/Foundation.h>

@interface PlatformUtils : NSObject

+ (BOOL)isSimulator;

@end

@implementation PlatformUtils

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#endif
    return NO;
}

@end

@interface TwilioVideoViewController () <UITextFieldDelegate, TVIParticipantDelegate, TVIRoomDelegate, TVIVideoViewDelegate, TVICameraCapturerDelegate>

#pragma mark Video SDK components

@property (nonatomic, strong) TVICameraCapturer *camera;
@property (nonatomic, strong) TVILocalVideoTrack *localVideoTrack;
@property (nonatomic, strong) TVILocalAudioTrack *localAudioTrack;
@property (nonatomic, strong) TVIParticipant *participant;
@property (nonatomic, strong) TVIParticipant *participant2;
@property (nonatomic, weak) TVIVideoView *remoteView;
@property (weak, nonatomic) IBOutlet TVIVideoView *remoteView2;
@property (nonatomic, strong) TVIRoom *room;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleButtonCenterXConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *switchCamImage;

#pragma mark UI Element Outlets and handles


// `TVIVideoView` created from a storyboard
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *micButton;
@property (nonatomic, weak) IBOutlet UIButton *flipCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *videoButton;

@end

@implementation TwilioVideoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[TwilioVideo version];
    //[self logMessage:[NSString stringWithFormat:@"TwilioVideo v%@", [TwilioVideo version]]];
    
    // Configure access token manually for testing, if desired! Create one manually in the console
    //self.accessToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJpc3MiOiJTSzBmZTUwZTQ2M2VlODZlNDNiMDgxMjYxYTA0ZGFjZDAwIiwiZXhwIjoxNTY3NDM5MjcwLCJqdGkiOiJTSzBmZTUwZTQ2M2VlODZlNDNiMDgxMjYxYTA0ZGFjZDAwLTE1Njc0MzU2NzAiLCJzdWIiOiJBQzNkZjU2OTU5MDc1N2U1NzEyZmEzY2ZhMzU4ZWQxMWUzIiwiZ3JhbnRzIjp7ImlkZW50aXR5IjoiaU9TIiwidmlkZW8iOnsicm9vbSI6IkRlbW8ifX19.hV5KiVD-OJ3NG_MYivV0oIaHK_fvafrJXNTEJYb17X4";
    
    // Preview our local camera track in the local video preview view.
    [self startPreview];
    
    // Disconnect and mic button will be displayed when client is connected to a room.
    // self.disconnectButton.hidden = YES;
    // self.micButton.hidden = YES;
    //[self setupRemoteView2];
    //self.remoteView2.backgroundColor = UIColor.greenColor;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
    self.disconnectButton.clipsToBounds = true;
    self.disconnectButton.layer.cornerRadius = self.disconnectButton.frame.size.width/2.0f;
    self.disconnectButton.backgroundColor = [UIColor redColor];
}

- (void)viewDidAppear:(BOOL)animated{
    
    //[self connectToRoom:@"Demo"];
}

#pragma mark - Public

- (void)connectToRoom:(NSString*)room {
    [self showRoomUI:YES];
    
    if ([self.accessToken isEqualToString:@"TWILIO_ACCESS_TOKEN"]) {
        [self logMessage:[NSString stringWithFormat:@"Fetching an access token"]];
        [self showRoomUI:NO];
    } else {
        [self doConnect:room];
    }
}

- (IBAction)disconnectButtonPressed:(id)sender {
    [self.room disconnect];
    [self dismissViewControllerAnimated:true completion:nil];
    [self.twPlugin localParticipantDisconnected];
    // Code for callback calling after button pressed
	//[self writeJavascript:@"alert('foo');"];
    
}

- (IBAction)micButtonPressed:(id)sender {
    
    // We will toggle the mic to mute/unmute and change the title according to the user action.
    
    if (self.localAudioTrack) {
        self.localAudioTrack.enabled = !self.localAudioTrack.isEnabled;
        
        // Toggle the button title
        if (self.localAudioTrack.isEnabled) {
            self.micButton.selected = false;
            //self.micButton.alpha = self.micButton.selected ? 0.7 : 1;
            // [self.micButton setTitle:@"Mute" forState:UIControlStateNormal];
        } else {
            // [self.micButton setTitle:@"Unmute" forState:UIControlStateNormal];
            self.micButton.selected = true;
            //self.micButton.alpha = self.micButton.selected ? 0.7 : 1;
        }
    }
}

- (IBAction)flipcameraButtonPressed:(id)sender {
    if(self.localVideoTrack){
        //  self.flipCameraButton.selected = !self.flipCameraButton.selected;
        //  self.flipCameraButton.alpha = self.flipCameraButton.selected ? 0.7 : 1;
        [self flipCamera];
    }
}

- (IBAction)videoButtonPressed:(id)sender {
    if(self.localVideoTrack){
        self.localVideoTrack.enabled = !self.localVideoTrack.isEnabled;
        
        if(self.localVideoTrack.isEnabled){
            self.switchCamImage.hidden = false;
            self.flipCameraButton.hidden = false;
            self.middleButtonCenterXConstraint.constant = 0;
            //[self.previewView addSubview:self.camera.previewView];
            self.videoButton.selected=false;
            self.previewView.hidden = false;

        }else {
            self.videoButton.selected=true;
            self.switchCamImage.hidden = true;
            self.flipCameraButton.hidden = true;
            self.middleButtonCenterXConstraint.constant = -35;
            //[self.camera.previewView removeFromSuperview];
            self.previewView.hidden = true;
        }
    }
}

#pragma mark - Private

- (void)startPreview {
    // TVICameraCapturer is not supported with the Simulator.
    if ([PlatformUtils isSimulator]) {
        [self.previewView removeFromSuperview];
        return;
    }
    
    //self.camera = [[TVICameraCapturer alloc] initWithSource:TVICameraCaptureSourceFrontCamera delegate:self];
    self.camera = [[TVICameraCapturer alloc] initWithSource:TVICameraCaptureSourceFrontCamera delegate:self enablePreview:true];
    self.localVideoTrack = [TVILocalVideoTrack trackWithCapturer:self.camera];
    if (!self.localVideoTrack) {
        //     [self logMessage:@"Failed to add video track"];
    } else {
        // Add renderer to video track for local preview
        // Commented the new line to try to fixe iPhone XR rotated view bug
        //[self.localVideoTrack addRenderer:self.previewView];
        
        //Rotated view bug solution
        //Start
        self.camera.previewView.frame = self.previewView.bounds;
        self.camera.previewView.contentMode = UIViewContentModeScaleAspectFill;
        [self.previewView addSubview:self.camera.previewView];
        self.previewView.backgroundColor = UIColor.blackColor;
        
        //[self logMessage:@"Video track created"];
        //End
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(flipCamera)];
        [self.previewView addGestureRecognizer:tap];
    }
}

- (void)flipCamera {
    if (self.camera.source == TVICameraCaptureSourceFrontCamera) {
        [self.camera selectSource:TVICameraCaptureSourceBackCameraWide];
    } else {
        [self.camera selectSource:TVICameraCaptureSourceFrontCamera];
    }
}

- (void)prepareLocalMedia {
    
    // We will share local audio and video when we connect to room.
    
    // Create an audio track.
    if (!self.localAudioTrack) {
        self.localAudioTrack = [TVILocalAudioTrack track];
        
        if (!self.localAudioTrack) {
            //         [self logMessage:@"Failed to add audio track"];
        }
    }
    
    // Create a video track which captures from the camera.
    if (!self.localVideoTrack) {
        [self startPreview];
    }
}

- (void)doConnect:(NSString*)room {
    if ([self.accessToken isEqualToString:@"TWILIO_ACCESS_TOKEN"]) {
        //   [self logMessage:@"Please provide a valid token to connect to a room"];
        return;
    }
    // Prepare local media which we will share with Room Participants.
    [self prepareLocalMedia];
    
    TVIConnectOptions *connectOptions = [TVIConnectOptions optionsWithToken:self.accessToken
                                                                      block:^(TVIConnectOptionsBuilder * _Nonnull builder) {
                                                                          
                                                                          // Use the local media that we prepared earlier.
                                                                          builder.audioTracks = self.localAudioTrack ? @[ self.localAudioTrack ] : @[ ];
                                                                          builder.videoTracks = self.localVideoTrack ? @[ self.localVideoTrack ] : @[ ];
                                                                          
                                                                          // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
                                                                          // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
                                                                          builder.roomName = room;
                                                                      }];
    
    // Connect to the Room using the options we provided.
    self.room = [TwilioVideo connectWithOptions:connectOptions delegate:self];
    
    //   [self logMessage:[NSString stringWithFormat:@"Attempting to connect to room %@", room]];
}

- (void)setupRemoteView {
    // Creating `TVIVideoView` programmatically
    TVIVideoView *remoteView = [[TVIVideoView alloc] init];
    
    // `TVIVideoView` supports UIViewContentModeScaleToFill, UIViewContentModeScaleAspectFill and UIViewContentModeScaleAspectFit
    // UIViewContentModeScaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
    //remoteView.contentMode = UIViewContentModeScaleAspectFit;
    remoteView.contentMode = UIViewContentModeScaleAspectFill;
    [remoteView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view insertSubview:remoteView atIndex:0];
    self.remoteView = remoteView;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:centerX];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:centerY];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:0];
    [self.view addConstraint:width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:0];
    [self.view addConstraint:height];
}

- (void)setupRemoteView2 {
    // Creating `TVIVideoView` programmatically
    //TVIVideoView *remoteView = [[TVIVideoView alloc] init];
    
    // `TVIVideoView` supports UIViewContentModeScaleToFill, UIViewContentModeScaleAspectFill and UIViewContentModeScaleAspectFit
    // UIViewContentModeScaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
    //self.remoteView2.contentMode = UIViewContentModeScaleAspectFill;
    [self.remoteView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.remoteView2.hidden = false;
    //[self.view insertSubview:remoteView atIndex:1];
    //self.remoteView2 = remoteView;
    
    /*NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.remoteView2
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeLeadingMargin
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:left];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.remoteView2
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.previewView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:-15];
    [self.view addConstraint:centerY];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.remoteView2
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.previewView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:0];
    
    
    [self.view addConstraint:width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.remoteView2
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.previewView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:0];
    [self.view addConstraint:height];**/
}

// Reset the client ui status
- (void)showRoomUI:(BOOL)inRoom {
    // self.micButton.hidden = !inRoom;
    // self.disconnectButton.hidden = !inRoom;
    [UIApplication sharedApplication].idleTimerDisabled = inRoom;
}

- (void)cleanupRemoteParticipant:(TVIParticipant *)participant  {
    if (self.participant == participant) {
        if ([self.participant.videoTracks count] > 0) {
            [self.participant.videoTracks[0] removeRenderer:self.remoteView];
            [self.remoteView removeFromSuperview];
        }
        self.participant = nil;
    }
	else if (self.participant2 == participant) {
        if ([self.participant2.videoTracks count] > 0) {
            [self.participant2.videoTracks[0] removeRenderer:self.remoteView2];
            self.remoteView2.hidden = true;
        }
        self.participant2 = nil;
    }
}

- (void)logMessage:(NSString *)msg {
    NSLog(@"%@", msg);
    self.messageLabel.text = msg;
}
#pragma mark - Gestures Handling Tap

- (void)dismissKeyboard{
    
}


#pragma mark - UITextFieldDelegate

#pragma mark - TVIRoomDelegate

- (void)didConnectToRoom:(TVIRoom *)room {
    
    // [self logMessage:[NSString stringWithFormat:@"Connected to room %@ as %@", room.name, room.localParticipant.identity]];
    // [self logMessage:@"Waiting on participant to join"];
    
    for (TVIParticipant *remoteParticipant in room.participants) {
        
        if(!self.participant){
            self.participant = remoteParticipant;
            self.participant.delegate = self;
        }
        else if(!self.participant2){
            self.participant2 = remoteParticipant;
            self.participant2.delegate = self;
        }
        
    }
}

- (void)room:(TVIRoom *)room didDisconnectWithError:(nullable NSError *)error {
    // [self logMessage:[NSString stringWithFormat:@"Disconncted from room %@, error = %@", room.name, error]];
    
    [self cleanupRemoteParticipant:nil];
    self.room = nil;
    
    [self showRoomUI:NO];
}

- (void)room:(TVIRoom *)room didFailToConnectWithError:(nonnull NSError *)error{
    //  [self logMessage:[NSString stringWithFormat:@"Failed to connect to room, error = %@", error]];
    
    self.room = nil;
    
    [self showRoomUI:NO];
}

- (void)room:(TVIRoom *)room participantDidConnect:(TVIParticipant *)participant {
    if (!self.participant) {
        self.participant = participant;
        self.participant.delegate = self;
    }
	else if (!self.participant2) {
        self.participant2 = participant;
        self.participant2.delegate = self;
    }
    // [self logMessage:[NSString stringWithFormat:@"Room %@ participant %@ connected", room.name, participant.identity]];
    // [self logMessage:@" "];
}

- (void)room:(TVIRoom *)room participantDidDisconnect:(TVIParticipant *)participant {
    if (self.participant == participant || self.participant2 == participant ) {
        [self cleanupRemoteParticipant:participant];
    }
    
    if(!self.participant && self.participant2){
        [self.participant2.videoTracks[0] removeRenderer:self.remoteView2];
        [self setupRemoteView];
        [self.participant2.videoTracks[0] addRenderer:self.remoteView];
        self.remoteView2.hidden = true;
        self.participant = self.participant2;
        self.participant2 = nil;
    }

    // [self logMessage:[NSString stringWithFormat:@"Room %@ participant %@ disconnected", room.name, participant.identity]];
    // [self logMessage:@"Participant disconnected"];

    // Automatically disconnect and finish if only one Participant is in the room - CHANGE FROM ORIGINAL
    //if(room.participants.count < 1){
    //    [self.room disconnect];
    //    [self dismissViewControllerAnimated:true completion:nil];
    //}
    // END CHANGE

}

#pragma mark - TVIParticipantDelegate

- (void)participant:(TVIParticipant *)participant addedVideoTrack:(TVIVideoTrack *)videoTrack {
     //[self logMessage:[NSString stringWithFormat:@"Participant %@ added video track.", participant.identity]];
    
    if (self.participant == participant) {
        [self setupRemoteView];
        [videoTrack addRenderer:self.remoteView];
    }
	else if(self.participant2 == participant) {
        [self setupRemoteView2];
        [videoTrack addRenderer:self.remoteView2];
    }
}

- (void)participant:(TVIParticipant *)participant removedVideoTrack:(TVIVideoTrack *)videoTrack {
    //   [self logMessage:[NSString stringWithFormat:@"Participant %@ removed video track.", participant.identity]];
    
    if (self.participant == participant) {
        [videoTrack removeRenderer:self.remoteView];
        [self.remoteView removeFromSuperview];
    }
	else if (self.participant2 == participant) {
        [videoTrack removeRenderer:self.remoteView2];
        self.remoteView2.hidden = true;
    }
}

- (void)participant:(TVIParticipant *)participant addedAudioTrack:(TVIAudioTrack *)audioTrack {
    //  [self logMessage:[NSString stringWithFormat:@"Participant %@ added audio track.", participant.identity]];
}

- (void)participant:(TVIParticipant *)participant removedAudioTrack:(TVIAudioTrack *)audioTrack {
    //  [self logMessage:[NSString stringWithFormat:@"Participant %@ removed audio track.", participant.identity]];
}

- (void)participant:(TVIParticipant *)participant enabledTrack:(TVITrack *)track {
    NSString *type = @"";
    if ([track isKindOfClass:[TVIAudioTrack class]]) {
        type = @"audio";
    } else {
        type = @"video";
    }
    //  [self logMessage:[NSString stringWithFormat:@"Participant %@ enabled %@ track.", participant.identity, type]];
}

- (void)participant:(TVIParticipant *)participant disabledTrack:(TVITrack *)track {
    NSString *type = @"";
    if ([track isKindOfClass:[TVIAudioTrack class]]) {
        type = @"audio";
    } else {
        type = @"video";
    }
    //  [self logMessage:[NSString stringWithFormat:@"Participant %@ disabled %@ track.", participant.identity, type]];
}

#pragma mark - TVIVideoViewDelegate

- (void)videoView:(TVIVideoView *)view videoDimensionsDidChange:(CMVideoDimensions)dimensions {
    NSLog(@"Dimensions changed to: %d x %d", dimensions.width, dimensions.height);
    [self.view setNeedsLayout];
}

#pragma mark - TVICameraCapturerDelegate

- (void)cameraCapturer:(TVICameraCapturer *)capturer didStartWithSource:(TVICameraCaptureSource)source {
    //self.previewView.mirror = (source == TVICameraCaptureSourceFrontCamera);
}

@end
