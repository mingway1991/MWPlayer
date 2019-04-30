//
//  MWPlayerInfo.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MWPlayerStateInit = 0,
    MWPlayerStatePlaying,
    MWPlayerStatePause,
    MWPlayerStatePlayFinished,
} MWPlayerState;

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerInfo : NSObject

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, assign) BOOL isPlaying; //用于更新播放状态还是暂停状态
@property (nonatomic, assign) BOOL isPlayFinished; //是否播放完成
@property (nonatomic, assign) NSTimeInterval totalTimeInterval;
@property (nonatomic, assign) NSTimeInterval cacheTimeInterval;
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;

@end

NS_ASSUME_NONNULL_END
