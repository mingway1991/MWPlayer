//
//  EVVideoListViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVVideoListViewController.h"
#import "MWPlayerView.h"
#import "MWPlayerConfiguration.h"

@interface EVVideoListViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *_videos;
}

@property (nonatomic, strong) UITableView *videoListTableView;

@property (nonatomic, strong) MWPlayerView *playerView;

@end

@implementation EVVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _videos = @[@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
                @"https://echo-video.oss-cn-shanghai.aliyuncs.com/movie.mp4"];
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor blackColor];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(20, 5, 60.f, 40.f);
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closePlayer) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:closeButton];
    
    MWPlayerConfiguration *configuration = [MWPlayerConfiguration defaultConfiguration];
    configuration.topToolView = topView;
    self.playerView.configuration = configuration;
    
    [self.view addSubview:self.videoListTableView];
    [self.view addSubview:self.playerView];
}

- (void)closePlayer {
    [self.playerView stop];
    self.playerView.hidden = YES;
}

#pragma mark -
#pragma mark UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _videos[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.playerView.hidden = NO;
    self.playerView.videoUrl = _videos[indexPath.row];
    [self.playerView play];
}

#pragma mark -
#pragma mark LazyLoad
- (UITableView *)videoListTableView {
    if (!_videoListTableView) {
        self.videoListTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _videoListTableView.dataSource = self;
        _videoListTableView.delegate = self;
    }
    return _videoListTableView;
}

- (MWPlayerView *)playerView {
    if (!_playerView) {
        self.playerView = [[MWPlayerView alloc] initWithFrame:CGRectMake(0, 64.f, CGRectGetWidth([UIScreen mainScreen].bounds), 300.f)];
        self.playerView.hidden = YES;
    }
    return _playerView;
}

@end
