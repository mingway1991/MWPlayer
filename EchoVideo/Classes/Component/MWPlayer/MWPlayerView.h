//
//  MWPlayerView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPlayerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class MWPlayerView;

@protocol MWPlayerViewDelegate <NSObject>

@optional
- (void)playerViewUpdateProgress:(MWPlayerView *)playerView
               totalTimeInterval:(NSTimeInterval)totalTimeInterval
             currentTimeInterval:(NSTimeInterval)currentTimeInterval;
- (void)playerViewLoadCache:(MWPlayerView *)playerView
          totalTimeInterval:(NSTimeInterval)totalTimeInterval
          cacheTimeInterval:(NSTimeInterval)cacheTimeInterval;
- (void)playerViewLoadBreak:(MWPlayerView *)playerView;

@end

@interface MWPlayerView : UIView

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *localUrl;
@property (nonatomic, strong) MWPlayerConfiguration *configuration; // 不赋值使用默认配置
@property (nonatomic, weak) id<MWPlayerViewDelegate> delegate;

/* 播放 */
- (void)play;
/* 暂停 */
- (void)pause;
/* 指定某处播放 */
- (void)seekToPlay:(float)percent;
/* 重置为未播放状态 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
