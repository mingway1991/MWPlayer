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
#import "EVRecordVideoViewController.h"
#import "EVLoadingHelper.h"
#import "EVVideoCell.h"

@import MJRefresh;

@interface EVVideoListViewController () <UITableViewDataSource, UITableViewDelegate, EVNewVideoViewDelegate, EVRecordVideoViewControllerDelegate>

@property (nonatomic, strong) NSNumber *after;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) UITableView *videoListTableView;
@property (nonatomic, strong) EVNetwork *network;
@property (nonatomic, strong) NSArray<EVVideoModel *> *videos;
@property (nonatomic, strong) NSDictionary *videoCombineDict; // 按日期归类后的videos
@property (nonatomic, strong) NSArray *videoCombineDictSortedKeys; // 字典的日期key数组

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
#pragma mark Private
/**
 组装日期-video字典
 */
- (void)_recombineVideos:(NSArray *)videos
               isRefresh:(BOOL)isRefresh {
    NSMutableDictionary *newDict;
    if (isRefresh) {
        newDict = [NSMutableDictionary dictionary];
    } else {
        newDict = [NSMutableDictionary dictionaryWithDictionary:self.videoCombineDict];
    }
    for (EVVideoModel *video in videos) {
        NSString *createdAt = video.created_at;
        NSDate *createdAtDate = [NSDate dateWithString:createdAt format:@"yyyy-MM-dd HH:mm:ss"];
        NSString *formattedCreatedAt = [createdAtDate stringWithFormat:@"yyyy-MM-dd"];
        NSMutableArray *videosArray = [newDict objectForKey:formattedCreatedAt];
        if (!videosArray) {
            videosArray = [NSMutableArray array];
        }
        [videosArray addObject:video];
        [newDict setObject:videosArray forKey:formattedCreatedAt];
    }
    NSArray *keysArray = [newDict allKeys];//获取所有键存到数组
    NSArray *sortedArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1 options:NSNumericSearch];
    }];
    self.videoCombineDict = newDict;
    self.videoCombineDictSortedKeys = sortedArray;
}

#pragma mark -
#pragma mark Action
- (void)newVideoAction:(UIBarButtonItem *)item {
    NSMutableArray *items = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [items addObject:[MWPopupItem itemWithIcon:nil title:@"添加链接" completion:^{
        EVNewVideoView *newVideoView = [[EVNewVideoView alloc] initWithType:EVNewVideoTypeUrl];
        newVideoView.delegate = weakSelf;
        [newVideoView show];
    }]];
    [items addObject:[MWPopupItem itemWithIcon:nil title:@"录制视频" completion:^{
        EVRecordVideoViewController *vc = [[EVRecordVideoViewController alloc] init];
        vc.delegate = weakSelf;
        [weakSelf.navigationController presentViewController:vc animated:YES completion:nil];
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
                           [weakSelf _recombineVideos:videos isRefresh:isRefresh];
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

- (void)createVideoWithTitle:(NSString *)title videoUrl:(NSString *)videoUrl completion:(void(^)(BOOL success, NSString *errorMsg))completion {
    [self.network createVideoWithTitle:title cover_url:nil video_url:videoUrl aid:self.album.album_id successBlock:^{
        completion(YES, nil);
    } failureBlock:^(NSString * _Nonnull msg) {
        completion(NO, msg);
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.videoCombineDictSortedKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *videos = [self.videoCombineDict objectForKey:self.videoCombineDictSortedKeys[section]];
    return videos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EVVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[EVVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSString *date = self.videoCombineDictSortedKeys[indexPath.section];
    EVVideoModel *video = [self.videoCombineDict objectForKey:date][indexPath.row];
    [cell updateUIWithVideo:video date:date index:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EVVideoModel *video = [self.videoCombineDict objectForKey:self.videoCombineDictSortedKeys[indexPath.section]][indexPath.row];
    EVPlayVideoViewController *vc = [[EVPlayVideoViewController alloc] init];
    vc.videos = @[video];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    EVLoadingHelper *helper = [[EVLoadingHelper alloc] init];
    [helper showLoadingHUDAddedToView:self.view text:@"加载中..."];
    __weak typeof(self) weakSelf = self;
    [self.network deleteVideoWithAid:self.album.album_id vid:[self.videos[indexPath.row] video_id] successBlock:^{
        [helper hideLoadingHUD];
        //删除数据，和删除动画
        NSMutableArray *newVideos = [NSMutableArray arrayWithArray:weakSelf.videos];
        [newVideos removeObjectAtIndex:indexPath.row];
        weakSelf.videos = newVideos;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    } failureBlock:^(NSString * _Nonnull msg) {
        [helper hideLoadingHUD];
    }];
}

#pragma mark -
#pragma mark EVNewVideoViewDelegate
- (void)newVideoView:(EVNewVideoView *)newVideoView title:(NSString *)title url:(NSString *)url {
    EVLoadingHelper *helper = [[EVLoadingHelper alloc] init];
    [helper showLoadingHUDAddedToView:newVideoView text:@"加载中..."];
    __weak typeof(self) weakSelf = self;
    [self createVideoWithTitle:title videoUrl:url completion:^(BOOL success, NSString *errorMsg) {
        [helper hideLoadingHUD];
        if (success) {
            [newVideoView hide];
            [weakSelf.videoListTableView.mj_header beginRefreshing];
        }
    }];
}

- (void)newVideoView:(EVNewVideoView *)newVideoView title:(NSString *)title localVideoPath:(NSString *)localVideoPath {
    EVLoadingHelper *helper = [[EVLoadingHelper alloc] init];
    [helper showLoadingHUDAddedToView:newVideoView text:@"加载中..."];
    __weak typeof(self) weakSelf = self;
    [[[EVNetwork alloc] init] uploadVideoWithLocalPath:localVideoPath successBlock:^(NSString * _Nonnull url) {
        [weakSelf createVideoWithTitle:title videoUrl:url completion:^(BOOL success, NSString *errorMsg) {
            [helper hideLoadingHUD];
            if (success) {
                [newVideoView hide];
                [weakSelf.videoListTableView.mj_header beginRefreshing];
            }
        }];
    } failureBlock:^(NSString * _Nonnull msg) {
        [helper hideLoadingHUD];
    }];
}

#pragma mark -
#pragma mark EVRecordVideoViewControllerDelegate
- (void)recordVideoViewController:(EVRecordVideoViewController *)recordVideoViewController
        finishRecordWithLocalPath:(NSString *)localPath {
    EVNewVideoView *newVideoView = [[EVNewVideoView alloc] initWithType:EVNewVideoTypeLocal];
    newVideoView.delegate = self;
    newVideoView.localVideoPath = localPath;
    [newVideoView show];
}

#pragma mark -
#pragma mark LazyLoad
- (UITableView *)videoListTableView {
    if (!_videoListTableView) {
        self.videoListTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _videoListTableView.dataSource = self;
        _videoListTableView.delegate = self;
        _videoListTableView.contentInset = UIEdgeInsetsMake(MWTopBarHeight, 0, 0, 0);
        _videoListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak typeof(self) weakSelf = self;
        _videoListTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
