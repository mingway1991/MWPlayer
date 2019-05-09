//
//  EVVideoListViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVVideoListViewController.h"
#import "EVVideoModel.h"
#import "EVNetwork+Video.h"
#import "EVNewVideoView.h"
#import "EVPlayVideoViewController.h"
#import "MWDefines.h"
#import "MWPopup.h"

@import MJRefresh;

@interface EVVideoListViewController () <UITableViewDataSource, UITableViewDelegate, EVNewVideoViewDelegate>

@property (nonatomic, strong) NSNumber *after;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) UITableView *videoListTableView;
@property (nonatomic, strong) EVNetwork *network;
@property (nonatomic, strong) NSArray<EVVideoModel *> *videos;

@end

@implementation EVVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self.videoListTableView.mj_header beginRefreshing];
}

- (void)initUI {
    [self.view addSubview:self.videoListTableView];
    
    UIBarButtonItem *newVideoBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newVideoAction:)];
    self.navigationItem.rightBarButtonItem = newVideoBarButton;
}

#pragma mark -
#pragma mark Setter
- (void)setAlbum:(EVAlbumModel *)album {
    _album = album;
    self.title = album.title;
}

#pragma mark -
#pragma mark Action
- (void)newVideoAction:(UIBarButtonItem *)item {
    NSMutableArray *items = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [items addObject:[MWPopupItem itemWithIcon:nil title:@"添加链接" completion:^{
        EVNewVideoView *newVideoView = [[EVNewVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        newVideoView.delegate = weakSelf;
        [newVideoView show];
    }]];
    [items addObject:[MWPopupItem itemWithIcon:nil title:@"录制视频" completion:^{
        
    }]];
    
    CGRect rect = [self.navigationController.view convertRect:[(UIView *)[item valueForKey:@"_view"] frame] fromView:[(UIView *)[item valueForKey:@"_view"] superview]];
    CGPoint point = CGPointMake(CGRectGetMinX(rect)+CGRectGetWidth(rect)/2.f, CGRectGetMaxY(rect));
    [MWPopup shared].itemWidth = 110.f;
    [[MWPopup shared] showWithItems:items arrowPoint:point];
}

#pragma mark -
#pragma mark Request
- (void)loadVideosWithIsRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        self.after = @(0);
    } else {
        self.after = self.videos.lastObject.video_id;
    }
    __weak typeof(self) weakSelf = self;
    [self.network loadVideosWithAid:self.album.album_id
                              after:self.after
                              count:self.count
                       successBlock:^(NSArray<EVVideoModel *> * _Nonnull videos) {
                           NSMutableArray *newVideos = [NSMutableArray arrayWithArray:weakSelf.videos];
                           if (isRefresh) {
                               newVideos = [videos mutableCopy];
                               [weakSelf.videoListTableView.mj_header endRefreshing];
                               if (videos.count == weakSelf.count.integerValue) {
                                   weakSelf.videoListTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                                       [weakSelf loadVideosWithIsRefresh:NO];
                                   }];
                               }
                           } else {
                               [newVideos addObjectsFromArray:videos];
                               if (videos.count < weakSelf.count.integerValue) {
                                   [weakSelf.videoListTableView.mj_footer endRefreshingWithNoMoreData];
                               } else {
                                   [weakSelf.videoListTableView.mj_footer endRefreshing];
                               }
                           }
                           weakSelf.videos = newVideos;
                           [weakSelf.videoListTableView reloadData];
    } failureBlock:^(NSString * _Nonnull msg) {
        if (isRefresh) {
            [weakSelf.videoListTableView.mj_header endRefreshing];
        } else {
            [weakSelf.videoListTableView.mj_header endRefreshing];
        }
    }];
}

- (void)createVideoWithTitle:(NSString *)title videoUrl:(NSString *)videoUrl completion:(void(^)(void))completion {
    [self.network createVideoWithTitle:title cover_url:nil video_url:videoUrl aid:self.album.album_id successBlock:^{
        completion();
    } failureBlock:^(NSString * _Nonnull msg) {
        
    }];
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
    cell.textLabel.text = [_videos[indexPath.row] title];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EVPlayVideoViewController *vc = [[EVPlayVideoViewController alloc] init];
    vc.videos = @[self.videos[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark EVNewVideoViewDelegate
- (void)newVideoView:(EVNewVideoView *)newVideoView title:(NSString *)title url:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    [self createVideoWithTitle:title videoUrl:url completion:^{
        [weakSelf.videoListTableView.mj_header beginRefreshing];
        [newVideoView hide];
    }];
}

#pragma mark -
#pragma mark LazyLoad
- (UITableView *)videoListTableView {
    if (!_videoListTableView) {
        self.videoListTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _videoListTableView.dataSource = self;
        _videoListTableView.delegate = self;
        _videoListTableView.contentInset = UIEdgeInsetsMake(MWTopBarHeight, 0, 0, 0);
        
        __weak typeof(self) weakSelf = self;
        _videoListTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
            [weakSelf loadVideosWithIsRefresh:YES];
        }];
    }
    return _videoListTableView;
}

- (EVNetwork *)network {
    if (!_network) {
        self.network = [[EVNetwork alloc] init];
    }
    return _network;
}

- (NSNumber *)after {
    if (!_after) {
        self.after = @(0);
    }
    return _after;
}

- (NSNumber *)count {
    if (!_count) {
        self.count = @(10);
    }
    return _count;
}

@end
