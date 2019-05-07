//
//  EVPlayVideoViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVPlayVideoViewController.h"
#import "MWPlayerView.h"
#import "MWPlayerConfiguration.h"
#import "MWDefines.h"

@interface EVPlayVideoViewController ()

@property (nonatomic, strong) MWPlayerView *playerView;
@property (nonatomic, strong) MWPlayerConfiguration *configuration;

@end

@implementation EVPlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.playerView];
}

- (void)dealloc {
    [_playerView stop];
    [_playerView removeFromSuperview];
}

- (void)playWithIndex:(NSInteger)index {
    self.title = [self.videos[index] title];
    self.playerView.hidden = NO;
    self.playerView.videoUrl = [self.videos[index] video_url];
    [self.playerView play];
}

#pragma mark -
#pragma mark Setter
- (void)setVideos:(NSArray<EVVideoModel *> *)videos {
    _videos = videos;
    
    [self playWithIndex:0];
}

#pragma mark -
#pragma mark LazyLoad
- (MWPlayerView *)playerView {
    if (!_playerView) {
        self.playerView = [[MWPlayerView alloc] initWithFrame:CGRectMake(0, MWTopBarHeight, CGRectGetWidth([UIScreen mainScreen].bounds), 300.f)];
        _playerView.hidden = YES;
        
        self.configuration = [MWPlayerConfiguration defaultConfiguration];
        _playerView.configuration = self.configuration;
    }
    return _playerView;
}

@end
