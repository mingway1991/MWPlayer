//
//  MWPlayerCoverView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPlayerInfo.h"
#import "MWPlayerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerCoverView : UIView

@property (nonatomic, weak) MWPlayerInfo *info;
@property (nonatomic, weak) MWPlayerConfiguration *configuration;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
