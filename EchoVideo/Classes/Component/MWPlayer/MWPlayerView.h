//
//  MWPlayerView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPlayerConfiguration.h"
#import "MWPlayerEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class MWPlayerView;

@protocol MWPlayerViewDelegate <NSObject>

@optional
// 更新播放进度
- (void)playerViewUpdateProgress:(MWPlayerView *)playerView
               totalTimeInterval:(NSTimeInterval)totalTimeInterval
             currentTimeInterval:(NSTimeInterval)currentTimeInterval;
// 更新缓存进度
- (void)playerViewLoadCache:(MWPlayerView *)playerView
          totalTimeInterval:(NSTimeInterval)totalTimeInterval
          cacheTimeInterval:(NSTimeInterval)cacheTimeInterval;
// 加载视频失败
- (void)playerViewLoadBreak:(MWPlayerView *)playerView;
// 更改播放器状态
- (void)playerViewChangedState:(MWPlayerView *)playerView
                         state:(MWPlayerState)state;
// 更改播放器方向
- (void)playerViewChangedDirection:(MWPlayerView *)playerView
                         direction:(MWPlayerDirection)direction;

@end

@interface MWPlayerView : UIView

@property (nonatomic, copy) NSString *videoUrl; // 网络视频
@property (nonatomic, copy) NSString *localUrl; // 本地视频
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
/* 调整播放器方向 */
- (void)changePlayerDirection:(MWPlayerDirection)direction;

@end

NS_ASSUME_NONNULL_END
