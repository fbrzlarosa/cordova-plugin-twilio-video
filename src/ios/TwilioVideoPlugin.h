//
//  TwilioVideoViewController.h
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

@import UIKit;
#import <Cordova/CDV.h>


@interface TwilioVideoPlugin : CDVPlugin

@property (nonatomic,retain) NSString  *callbackId;

- (void) localParticipantDisconnected;


@end
