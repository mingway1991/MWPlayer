//
//  EVLoadingHelper.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/14.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVLoadingHelper : NSObject

- (void)showLoadingHUDAddedToView:(UIView *)view;
- (void)showLoadingHUDAddedToView:(UIView *)view text:(NSString * _Nullable)text;
- (void)hideLoadingHUD;

@end

NS_ASSUME_NONNULL_END
