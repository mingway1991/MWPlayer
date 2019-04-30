//
//  MWPlayerCoverView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPlayerInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerCoverView : UIView

@property (nonatomic, strong) MWPlayerInfo *info;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
