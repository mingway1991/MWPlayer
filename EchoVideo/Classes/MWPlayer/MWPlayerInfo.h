//
//  MWPlayerInfo.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

#define degreeToRadian(x) (M_PI * x / 180.0)
#define radianToDegree(x) (180.0 * x / M_PI)

typedef enum : NSUInteger {
    MWPlayerStateInit = 0,
    MWPlayerStatePlaying,
    MWPlayerStatePause,
    MWPlayerStateStop,
    MWPlayerStatePlayFinished,
} MWPlayerState; // 播放器状态

typedef enum : NSUInteger {
    MWPlayerDirectionPortrait,
    MWPlayerDirectionLandscapeLeft,
    MWPlayerDirectionLandscapeRight,
} MWPlayerDirection; // 播放器方向

static NSString *kStateKeyPath = @"state";
static NSString *kTotalTimeIntervalKeyPath = @"totalTimeInterval";
static NSString *kCacheTimeIntervalKeyPath = @"cacheTimeInterval";
static NSString *kCurrentTimeIntervalKeyPath = @"currentTimeInterval";
static NSString *kPanToPlayPercentKeyPath = @"panToPlayPercent";
static NSString *kDirectionKeyPath = @"direction";

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerInfo : NSObject

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, assign) MWPlayerState state;
@property (nonatomic, assign) NSTimeInterval totalTimeInterval;
@property (nonatomic, assign) NSTimeInterval cacheTimeInterval;
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;
@property (nonatomic, assign) MWPlayerDirection direction;
// 临时标记需要跳到的进度
@property (nonatomic, assign) float panToPlayPercent;

@end

NS_ASSUME_NONNULL_END
