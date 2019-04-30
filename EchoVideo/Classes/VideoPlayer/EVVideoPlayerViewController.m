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
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(0, 0, 100.f, 60.f);
    playButton.backgroundColor = [UIColor redColor];
    [playButton addTarget:self action:@selector(clickPlayButton) forControlEvents:UIControlEventTouchUpInside];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.center = self.view.center;
    [self.view addSubview:playButton];
    
    [self.view addSubview:self.playerView];
}

- (void)clickPlayButton {
    // http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
    // https://echo-video.oss-cn-shanghai.aliyuncs.com/movie.mp4
    self.playerView.hidden = NO;
    self.playerView.videoUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    [self.playerView play];
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
