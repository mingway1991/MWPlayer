//
//  EVLoadingHelper.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/14.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVLoadingHelper.h"
#import "MBProgressHUD.h"

@interface EVLoadingHelper ()

@property (nonatomic, strong) MBProgressHUD *loadingHUD;

@end

@implementation EVLoadingHelper

- (void)showLoadingHUDAddedToView:(UIView *)view {
    [self showLoadingHUDAddedToView:view text:nil];
}

- (void)showLoadingHUDAddedToView:(UIView *)view text:(NSString * _Nullable)text {
    self.loadingHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    self.loadingHUD.mode = MBProgressHUDModeAnnularDeterminate;
    if (text) {
        self.loadingHUD.label.text = text;
    }
}

- (void)hideLoadingHUD {
    [self.loadingHUD hideAnimated:YES];
}

@end
