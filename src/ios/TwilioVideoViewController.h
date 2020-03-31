//
//  TwilioVideoViewController.h
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

@import UIKit;
#import <Cordova/CDV.h>
#import "TwilioVideoPlugin.h"

@interface TwilioVideoViewController : UIViewController


@property (nonatomic, strong) TwilioVideoPlugin * twPlugin;
@property (nonatomic, strong) NSString *accessToken;

- (void)connectToRoom:(NSString*)room ;

@end
