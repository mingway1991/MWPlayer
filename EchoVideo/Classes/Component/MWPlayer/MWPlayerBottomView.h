//
//  MWPlayerBottomView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPlayerInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerBottomView : UIView

@property (nonatomic, weak) MWPlayerInfo *info;

- (void)cleanObserver;

@end

NS_ASSUME_NONNULL_END
