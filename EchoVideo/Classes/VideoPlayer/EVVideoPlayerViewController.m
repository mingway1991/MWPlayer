//
//  EVVideoPlayerViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVVideoPlayerViewController.h"
#import "MWPlayerView.h"

@interface EVVideoPlayerViewController ()

@property (nonatomic, strong) MWPlayerView *playerView;

@end

@implementation EVVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *playButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton1.frame = CGRectMake(0, 0, 100.f, 60.f);
    playButton1.backgroundColor = [UIColor redColor];
    [playButton1 addTarget:self action:@selector(clickPlayButton1) forControlEvents:UIControlEventTouchUpInside];
    [playButton1 setTitle:@"Play" forState:UIControlStateNormal];
    playButton1.center = self.view.center;
    [self.view addSubview:playButton1];
    
    UIButton *playButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton2.frame = CGRectMake(CGRectGetMinX(playButton1.frame), CGRectGetMaxY(playButton1.frame)+10, 100.f, 60.f);
    playButton2.backgroundColor = [UIColor redColor];
    [playButton2 addTarget:self action:@selector(clickPlayButton2) forControlEvents:UIControlEventTouchUpInside];
    [playButton2 setTitle:@"Play" forState:UIControlStateNormal];
    [self.view addSubview:playButton2];
    
    UIButton *playButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton3.frame = CGRectMake(CGRectGetMinX(playButton2.frame), CGRectGetMaxY(playButton2.frame)+10, 100.f, 60.f);
    playButton3.backgroundColor = [UIColor redColor];
    [playButton3 addTarget:self action:@selector(clickPlayButton3) forControlEvents:UIControlEventTouchUpInside];
    [playButton3 setTitle:@"Stop" forState:UIControlStateNormal];
    [self.view addSubview:playButton3];
    
    [self.view addSubview:self.playerView];
}

- (void)clickPlayButton1 {
    // http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
    // https://echo-video.oss-cn-shanghai.aliyuncs.com/movie.mp4
    self.playerView.hidden = NO;
    self.playerView.videoUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    [self.playerView play];
}

- (void)clickPlayButton2 {
    // http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
    // https://echo-video.oss-cn-shanghai.aliyuncs.com/movie.mp4
    self.playerView.hidden = NO;
    self.playerView.videoUrl = @"https://echo-video.oss-cn-shanghai.aliyuncs.com/movie.mp4";
    [self.playerView play];
}

- (void)clickPlayButton3 {
    [self.playerView stop];
}

#pragma mark -
#pragma mark LazyLoad
- (MWPlayerView *)playerView {
    if (!_playerView) {
        self.playerView = [[MWPlayerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 300.f)];
        self.playerView.hidden = YES;
    }
    return _playerView;
}

@end
