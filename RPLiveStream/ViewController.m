//
//  ViewController.m
//  RPLiveStream
//
//  Created by annidyfeng on 2018/2/8.
//  Copyright © 2018年 annidy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<RPBroadcastActivityViewControllerDelegate,RPBroadcastControllerDelegate>
@property (nonatomic, weak) UIButton *liveBtn;
@property (nonatomic, weak) UIButton *stopBtn;
@property RPBroadcastController *broadcastController;
@property NSTimer *timer;
@property AVPlayer *soundPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
    
    self.soundPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"http://qqma.tingge123.com:83/123/2014/05/Reminiscent-%E6%9D%8E%E9%97%B0%E7%8F%89.mp3"]];
    
    self.soundPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.soundPlayer currentItem]];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    NSUInteger lineY = 20;
    
    UIButton *start = [UIButton buttonWithType:UIButtonTypeCustom];
    self.liveBtn = start;
    [self.view addSubview:start];
    [start setTitle:@"开始直播" forState:UIControlStateNormal];
    start.frame = CGRectMake(0, lineY, 150, 50);
    start.backgroundColor = [UIColor blueColor];
    [start addTarget:self action:@selector(startClicked:) forControlEvents:UIControlEventTouchUpInside];
    lineY += 50;
    
    UIButton *stop = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopBtn = stop;
    [self.view addSubview:stop];
    [stop setTitle:@"停止直播" forState:UIControlStateNormal];
    stop.frame = CGRectMake(0, lineY, 150, 50);
    stop.backgroundColor = [UIColor redColor];
    [stop addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.stopBtn.enabled = NO;
    lineY += 50;
    
    
}

- (void)startClicked:(UIButton *)btn
{
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        if (error) {
            NSLog(@"start broadcastActivityViewController error - %@",error);
        }
        broadcastActivityViewController.delegate = self;
        [self presentViewController:broadcastActivityViewController animated:YES completion:^{
            
        }];
        self.liveBtn.enabled = NO;
    }];
    [self.soundPlayer play];
}

- (void)stopClicked:(UIButton *)btn
{
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"finishBroadcastWithHandler %@", error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
            self.liveBtn.enabled = YES;
            [self.timer invalidate];
            self.timer = nil;
            self.liveBtn.titleLabel.alpha = 1;
        });
    }];
    [self.soundPlayer pause];
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes
{
    NSLog(@"activity - %@",activityTypes);
}

-(void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError *)error{
    NSLog(@"broadcastController:didFinishWithError"  );
    
}

-(void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(RPPreviewViewController *)previewViewController{
    NSLog(@"didStopRecordingWithError: %@", error);
}


-(void)broadcastController:(RPBroadcastController *)broadcastController didUpdateServiceInfo:(NSDictionary<NSString *,NSObject<NSCoding> *> *)serviceInfo{
    NSLog(@"broadcastController didUpdateServiceInfo: %@", serviceInfo);
}

-(void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error{
    NSLog(@"broadcastActivityViewController"  );
    
    
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:NULL];
    
    if (error)
    {
        NSLog(@"    error=%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.liveBtn.enabled = YES;
        });
        return;
    }
    
    NSLog(@"    broadcastController.broadcasting=%d", broadcastController.broadcasting);
    NSLog(@"    broadcastController.paused=%d", broadcastController.paused);
    NSLog(@"    broadcastController.broadcastURL=%@", broadcastController.broadcastURL);
    NSLog(@"    broadcastController.serviceInfo=%@", broadcastController.serviceInfo);
    NSLog(@"    broadcastController.broadcastExtensionBundleID=%@", broadcastController.broadcastExtensionBundleID);

    self.broadcastController = broadcastController;
    broadcastController.delegate = self;
    
    [self.liveBtn setTitle:@"正在初始化…" forState:UIControlStateNormal];
    
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"    直播中....."  );
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.liveBtn setTitle:@"直播中" forState:UIControlStateNormal];
                self.stopBtn.enabled = YES;
                if (self.timer == nil) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                        [UIView beginAnimations:@"blink" context:nil];
                        if (self.liveBtn.titleLabel.alpha == 0) {
                            self.liveBtn.titleLabel.alpha = 1;
                        } else {
                            self.liveBtn.titleLabel.alpha = 0;
                        }
                        [UIView commitAnimations];
                    }];
                }
            });
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error description] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
            self.liveBtn.enabled = YES;
        }
    }];
}

@end
