//
//  EVHomeViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVHomeViewController.h"
#import "EVAlbumModel.h"
#import "EVNetwork+Album.h"
#import "EVVideoListViewController.h"
#import "MWDefines.h"

@import MJRefresh;

@interface EVHomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) EVNetwork *network;
@property (nonatomic, strong) NSArray<EVAlbumModel *> *albums;

@end

@implementation EVHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"专辑";
    [self.view addSubview:self.albumTableView];
    [self loadAlbums];
}

#pragma mark -
#pragma mark Request
- (void)loadAlbums {
    __weak typeof(self) weakSelf = self;
    [self.network loadAlbumsWithSuccessBlock:^(NSArray<EVAlbumModel *> * _Nonnull albums) {
        [weakSelf.albumTableView.mj_header endRefreshing];
        weakSelf.albums = albums;
        [weakSelf.albumTableView reloadData];
    } failureBlock:^(NSString * _Nonnull msg) {
        [weakSelf.albumTableView.mj_header endRefreshing];
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.albums[indexPath.row] title];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EVVideoListViewController *vc = [[EVVideoListViewController alloc] init];
    vc.album = self.albums[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark LazyLoad
- (UITableView *)albumTableView {
    if (!_albumTableView) {
        self.albumTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _albumTableView.dataSource = self;
        _albumTableView.delegate = self;
        _albumTableView.contentInset = UIEdgeInsetsMake(MWTopBarHeight, 0, 0, 0);
        
        __weak typeof(self) weakSelf = self;
        _albumTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf loadAlbums];
        }];
    }
    return _albumTableView;
}

- (EVNetwork *)network {
    if (!_network) {
        self.network = [[EVNetwork alloc] init];
    }
    return _network;
}

@end
