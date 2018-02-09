//
//  BroadcastSetupViewController.m
//  ExtUploadUI
//
//  Created by annidyfeng on 2018/2/8.
//  Copyright © 2018年 annidy. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@interface BroadcastSetupViewController()
@property (weak) IBOutlet UITextField *urlTextField;
@end

@implementation BroadcastSetupViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self view]; // forces view load
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.urlTextField.text = [defaults objectForKey:@"rtmpUrl"];
}

// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (IBAction)userDidFinishSetup {
    if (self.urlTextField.text.length == 0)
        return;
    
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:self.urlTextField.text];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    CGSize sz = [[UIScreen mainScreen] bounds].size;
    
    NSString *endpointURL = self.urlTextField.text;
    NSDictionary *setupInfo = @{ @"endpointURL" : endpointURL, @"rotate":@(sz.width>sz.height) };
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:endpointURL forKey:@"rtmpUrl"];
    [defaults synchronize];
}

- (IBAction)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

@end
