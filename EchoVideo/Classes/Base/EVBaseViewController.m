//
//  EVBaseViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVBaseViewController.h"
#import "UIColor+MWUtil.h"

@interface EVBaseViewController ()

@end

@implementation EVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)dealloc {
    NSLog(@"dealloc - %@", [self class]);
}

// 状态栏文字颜色：默认黑色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

// 状态栏：默认不隐藏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

// 状态栏隐藏动画：默认渐变动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

@end
