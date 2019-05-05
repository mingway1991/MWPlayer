//
//  EVHomeViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVHomeViewController.h"
#import "EVVideoListViewController.h"

@interface EVHomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *listTableView;

@end

@implementation EVHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.listTableView];
}

#pragma mark -
#pragma mark UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"视频列表";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        EVVideoListViewController *vc = [[EVVideoListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -
#pragma mark LazyLoad
- (UITableView *)listTableView {
    if (!_listTableView) {
        self.listTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _listTableView.dataSource = self;
        _listTableView.delegate = self;
    }
    return _listTableView;
}

@end
