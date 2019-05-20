//
//  MWPlayerInfo.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPlayerEnum.h"

// kvo 使用
static NSString *kInfoStateKeyPath = @"state";
static NSString *kInfoTotalTimeIntervalKeyPath = @"totalTimeInterval";
static NSString *kInfoCacheTimeIntervalKeyPath = @"cacheTimeInterval";
static NSString *kInfoCurrentTimeIntervalKeyPath = @"currentTimeInterval";
static NSString *kInfoPanToPlayPercentKeyPath = @"panToPlayPercent";
static NSString *kInfoDirectionKeyPath = @"direction";
static NSString *kInfoErrorMessageKeyPath = @"errMessage";

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerInfo : NSObject

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *localUrl;
@property (nonatomic, assign) MWPlayerState state;
@property (nonatomic, assign) NSTimeInterval totalTimeInterval;
@property (nonatomic, assign) NSTimeInterval cacheTimeInterval;
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;
@property (nonatomic, assign) MWPlayerDirection direction;
// 临时标记需要跳到的进度
@property (nonatomic, assign) float panToPlayPercent;
@property (nonatomic, copy, nullable) NSString *errMessage;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
