//
//  MWPlayerEnum.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/20.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#ifndef MWPlayerEnum_h
#define MWPlayerEnum_h

typedef enum : NSUInteger {
    MWPlayerStateInit = 0, // 初始状态
    MWPlayerStatePrepareToPlay, // 准备播放
    MWPlayerStatePlaying, // 正在播放
    MWPlayerStatePause, // 暂停
    MWPlayerStateStop, // 停止
    MWPlayerStatePlayFinished, // 播放完成
    MWPlayerStateLoadBreak, // 加载失败
} MWPlayerState; // 播放器状态

typedef enum : NSUInteger {
    MWPlayerDirectionPortrait,
    MWPlayerDirectionLandscapeLeft,
    MWPlayerDirectionLandscapeRight,
} MWPlayerDirection; // 播放器方向

typedef enum : NSUInteger {
    MWPlayerVideoGravityResizeAspect = 0, // 按比例完整显示
    MWPlayerVideoGravityResizeAspectFill, // 按比例充满屏幕
    MWPlayerVideoGravityResize
} MWPlayerVideoGravity; // 播放器填充方式

#endif /* MWPlayerEnum_h */
