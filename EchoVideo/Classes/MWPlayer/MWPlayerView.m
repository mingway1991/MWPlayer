//
//  MWPlayerView.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPlayerView.h"
#import "MWDefines.h"
#import "MWPlayerCoverView.h"
#import "MWPlayerInfo.h"

static NSString *kAvPlaterStatusKeyPath = @"status";
static NSString *kAvPlaterLoadedTimeRangesKeyPath = @"loadedTimeRanges";
static NSString *kAvPlaterPlaybackLikelyToKeepUpKeyPath = @"playbackLikelyToKeepUp"; // 进行跳转后有数据
static NSString *kAvPlaterPlaybackBufferEmptyKeyPath = @"playbackBufferEmpty"; // 进行跳转后没数据

@import AVFoundation;

@interface MWPlayerView () {
    UIView *_superView; // 保存父视图，便于全屏后恢复
    CGRect _originFrame; // 保存原始frame，便于全屏后恢复
}

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) MWPlayerInfo *info;
@property (nonatomic, strong) CADisplayLink *loadingDisplayLink;

@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) UIView<MWPlayerLoadingProtocol> *loadingView;
@property (nonatomic, strong) MWPlayerCoverView *coverView;

@end

@implementation MWPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    self.configuration = [MWPlayerConfiguration defaultConfiguration];
    self.info = [[MWPlayerInfo alloc] init];
    self.coverView.info = self.info;
    [self _addInfoPropertyObserver];
    self.info.state = MWPlayerStateInit;
    
    __weak __typeof(self) weakSelf = self;
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, self.configuration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.info.state == MWPlayerStatePrepareToPlay || weakSelf.info.state == MWPlayerStateInit) {
            weakSelf.info.state = MWPlayerStatePlaying;
        }
        NSTimeInterval current = CMTimeGetSeconds(time);
        NSTimeInterval total = CMTimeGetSeconds(weakSelf.avPlayer.currentItem.duration);
        if (current > total || total <= 0 || total != total || current != current) {
            current = 0;
            total = 0;
        }
        weakSelf.info.totalTimeInterval = total;
        weakSelf.info.currentTimeInterval = current;
    }];
    
    [self.layer addSublayer:self.avPlayerLayer];
    [self addSubview:self.coverView];
    [self _addLoadingView];
    
    self.loadingDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_upadteLoading)];
    [self.loadingDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)dealloc {
    NSLog(@"mwplayerview dealloc");
    [_loadingDisplayLink invalidate];
    [self _releaseConfigurationPropertyObserver];
    [self _releaseInfoPropertyObserver];
    [self _releaseCurrentAvPlayerItemObserver];
    [_avPlayer removeTimeObserver:self];
    [_avPlayerLayer removeFromSuperlayer];
    _loadingDisplayLink = nil;
    _info = nil;
    _configuration = nil;
    _avPlayer = nil;
    _avPlayerLayer = nil;
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.avPlayerLayer.frame = self.bounds;
    self.coverView.frame = self.bounds;
    [self _updateLoadingViewFrame];
}

#pragma mark -
#pragma mark Setter
- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    [self _releaseCurrentAvPlayerItemObserver];
    if (videoUrl.length > 0) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];
        [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self _addCurrentAvPlayerItemObserver];
    } else {
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    }
    
    self.info.videoUrl = videoUrl;
    self.info.cacheTimeInterval = 0;
    self.info.currentTimeInterval = 0;
    self.info.totalTimeInterval = 0;
}

- (void)setConfiguration:(MWPlayerConfiguration *)configuration {
    [self _releaseConfigurationPropertyObserver];
    _configuration = configuration;
    [self _addConfigurationPropertyObserver];
    [self _addLoadingView];
    [self _updateLoadingViewFrame];
    self.coverView.configuration = configuration;
}

#pragma mark -
#pragma mark Public
- (void)play {
    self.info.state = MWPlayerStatePrepareToPlay;
}

- (void)pause {
    self.info.state = MWPlayerStatePause;
}

- (void)seekToPlay:(float)percent {
    [self _changeProgressWithPercent:percent needPlay:YES];
}

- (void)stop {
    self.info.state = MWPlayerStateStop;
}

#pragma mark -
#pragma mark Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        // AVPlayerItem 监听
        if ([keyPath isEqualToString:kAvPlaterStatusKeyPath]) {
            AVPlayerItem *playerItem = (AVPlayerItem *)object;
            // avplaer load status
            if (playerItem.status == AVPlayerItemStatusReadyToPlay){
                NSLog(@"playerItem is ready");
            } else{
                NSLog(@"load break");
                self.info.state = MWPlayerStateLoadBreak;
            }
        } else if ([keyPath isEqualToString:kAvPlaterLoadedTimeRangesKeyPath]) {
            AVPlayerItem *playerItem = (AVPlayerItem *)object;
            // avplayer buffer
            NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
            NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
            NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval cache = startSeconds + durationSeconds;
            NSTimeInterval total = CMTimeGetSeconds(playerItem.duration);
            self.info.totalTimeInterval = total;
            self.info.cacheTimeInterval = cache;
            
            if (self.info.state == MWPlayerStatePlaying) {
                // 缓冲增加，继续播放
                NSTimeInterval current = CMTimeGetSeconds(self.avPlayer.currentTime);
                if (current == self.info.currentTimeInterval) {
                    // 判断正在缓冲卡顿中
                    if (cache > (current+1) || total < (current+2)) {
                        // 缓冲秒数大于当前秒数1秒以上尝试继续播放，或者是当前播放进度还剩2秒之内，则一直请求播放
                        self.info.state = MWPlayerStatePrepareToPlay;
                    }
                }
            }
        } else if ([keyPath isEqualToString:kAvPlaterPlaybackBufferEmptyKeyPath]) {
            // avplaer playback buffer empty
            
        } else if ([keyPath isEqualToString:kAvPlaterPlaybackLikelyToKeepUpKeyPath]) {
            // avplaer playback likely to keepup
            
        }
    } else if ([object isKindOfClass:[MWPlayerInfo class]]) {
        // MWPlayerInfo 监听
        if ([keyPath isEqualToString:kInfoStateKeyPath]) {
            // 更改播放状态
            if (self.info.state == MWPlayerStateInit) {
                [self _init];
            } else if (self.info.state == MWPlayerStatePrepareToPlay) {
                [self _play];
            } else if (self.info.state == MWPlayerStatePlaying) {
                // 正在播放
            } else if (self.info.state == MWPlayerStatePause) {
                [self _pause];
            } else if (self.info.state == MWPlayerStateStop) {
                [self _stop];
            } else if (self.info.state == MWPlayerStatePlayFinished) {
                [self _changeProgressWithPercent:0 needPlay:self.configuration.needLoop];
            } else if (self.info.state == MWPlayerStateLoadBreak) {
                [self _loadBreak];
            }
        } else if ([keyPath isEqualToString:kInfoPanToPlayPercentKeyPath]) {
            // 更改播放进度
            [self _changeProgressWithPercent:self.info.panToPlayPercent needPlay:NO];
        } else if ([keyPath isEqualToString:kInfoDirectionKeyPath]) {
            // 更改播放器方向
            if (self.info.direction == MWPlayerDirectionPortrait) {
                [self _zoomOut];
            } else {
                [self _zoomInWithDirection:self.info.direction];
            }
        }
    } else if ([object isKindOfClass:[MWPlayerConfiguration class]]) {
        // MWPlayerConfiguration 监听
        if ([keyPath isEqualToString:kConfigurationLoadingViewKeyPath]) {
            [self _addLoadingView];
        }
    }
}

/* 监听播放完成状态 */
- (void)observePlaybackFinished:(NSNotification *)notification {
    self.info.state = MWPlayerStatePlayFinished;
}

#pragma mark -
#pragma mark Private
/* 初始状态播放器 */
- (void)_init {
    [self.coverView show];
}

/* 播放 */
- (void)_play {
    [self.avPlayer play];
    [self.coverView show];
}

/* 暂停 */
- (void)_pause {
    [self.avPlayer pause];
    [self.coverView show];
}

/* 停止 */
- (void)_stop {
    self.info.cacheTimeInterval = 0;
    self.info.currentTimeInterval = 0;
    self.info.totalTimeInterval = 0;
    self.info.panToPlayPercent = 0;
    [self.avPlayer.currentItem cancelPendingSeeks];
    [self.avPlayer.currentItem.asset cancelLoading];
    [self _releaseCurrentAvPlayerItemObserver];
    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    [self.coverView show];
}

/* 拖动进度条 */
- (void)_changeProgressWithPercent:(float)percent
                          needPlay:(BOOL)needPlay {
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay && self.avPlayer.currentItem) {
        NSTimeInterval duration = percent * CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        [self.avPlayer seekToTime:seekTime
                  toleranceBefore:kCMTimeZero
                   toleranceAfter:kCMTimeZero
                completionHandler:^(BOOL finished) {
                    if (finished) {
                        if (needPlay) {
                            self.info.state = MWPlayerStatePrepareToPlay;
                        }
                    }
        }];
    }
}

/* 加载失败 */
- (void)_loadBreak {
    [self _changeProgressWithPercent:0 needPlay:NO];
    [self.avPlayer pause];
    [self.coverView show];
}

/* 更新loading状态 */
- (void)_upadteLoading {
    switch (self.info.state) {
        case MWPlayerStatePrepareToPlay: {
            // 准备播放状态默认显示加载中
            [self.loadingView startAnimating];
            break;
        }
        case MWPlayerStatePlaying: {
            // 播放状态下，判断是否处于加载中状态
            NSTimeInterval current = CMTimeGetSeconds(self.avPlayer.currentTime);
            if (current != self.info.currentTimeInterval) {
                [self.loadingView stopAnimating];
            } else {
                [self.loadingView startAnimating];
            }
            break;
        }
        default: {
            // 默认
            [self.loadingView stopAnimating];
            break;
        }
    }
}

/// full screen
/* 全屏 */
- (void)_zoomInWithDirection:(MWPlayerDirection)direction {
    _superView = self.superview;
    _originFrame = self.frame;
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    if (direction == MWPlayerDirectionLandscapeLeft) {
        [self.avPlayerLayer setAffineTransform:CGAffineTransformMakeRotation(MWDegreeToRadian(90))];
        [self.coverView.layer setAffineTransform:CGAffineTransformMakeRotation(MWDegreeToRadian(90))];
    } else if (direction == MWPlayerDirectionLandscapeRight) {
        [self.avPlayerLayer setAffineTransform:CGAffineTransformMakeRotation(MWDegreeToRadian(-90))];
        [self.coverView.layer setAffineTransform:CGAffineTransformMakeRotation(MWDegreeToRadian(-90))];
    }
}

/* 缩小窗口 */
- (void)_zoomOut {
    self.frame = _originFrame;
    [_superView addSubview:self];
    [self.avPlayerLayer setAffineTransform:CGAffineTransformIdentity];
    [self.coverView.layer setAffineTransform:CGAffineTransformIdentity];
}

/// loading
- (void)_addLoadingView {
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
    }
    self.loadingView = self.configuration.loadingView;
    [self insertSubview:self.loadingView belowSubview:self.coverView];
}

- (void)_updateLoadingViewFrame {
    self.loadingView.frame = self.bounds;
}

/// observer
/* 取消当前avplayer playitem 监听 */
- (void)_releaseCurrentAvPlayerItemObserver {
    if (_avPlayer && _avPlayer.currentItem) {
        [_avPlayer.currentItem removeObserver:self forKeyPath:kAvPlaterStatusKeyPath];
        [_avPlayer.currentItem removeObserver:self forKeyPath:kAvPlaterLoadedTimeRangesKeyPath];
        [_avPlayer.currentItem removeObserver:self forKeyPath:kAvPlaterPlaybackBufferEmptyKeyPath];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

/* 添加当前avplayer playitem 监听 */
- (void)_addCurrentAvPlayerItemObserver {
    if (_avPlayer && _avPlayer.currentItem) {
        [_avPlayer.currentItem addObserver:self forKeyPath:kAvPlaterStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_avPlayer.currentItem addObserver:self forKeyPath:kAvPlaterLoadedTimeRangesKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_avPlayer.currentItem addObserver:self forKeyPath:kAvPlaterPlaybackBufferEmptyKeyPath options:NSKeyValueObservingOptionNew context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observePlaybackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
    }
}

/* 取消info属性监听 */
- (void)_releaseInfoPropertyObserver {
    if (_info) {
        [_info removeObserver:self forKeyPath:kInfoStateKeyPath];
        [_info removeObserver:self forKeyPath:kInfoPanToPlayPercentKeyPath];
        [_info removeObserver:self forKeyPath:kInfoDirectionKeyPath];
    }
}

/* 添加info属性监听 */
- (void)_addInfoPropertyObserver {
    if (_info) {
        [_info addObserver:self forKeyPath:kInfoStateKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_info addObserver:self forKeyPath:kInfoPanToPlayPercentKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_info addObserver:self forKeyPath:kInfoDirectionKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

/* 取消configuration属性监听 */
- (void)_releaseConfigurationPropertyObserver {
    if (_configuration) {
        [_configuration removeObserver:self forKeyPath:kConfigurationLoadingViewKeyPath];
    }
}

/* 添加configuration属性监听 */
- (void)_addConfigurationPropertyObserver {
    if (_configuration) {
        [_configuration addObserver:self forKeyPath:kConfigurationLoadingViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark -
#pragma mark LazyLoad
- (MWPlayerCoverView *)coverView {
    if (!_coverView) {
        self.coverView = [[MWPlayerCoverView alloc] init];
    }
    return _coverView;
}

- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        self.avPlayer = [[AVPlayer alloc] init];
    }
    return _avPlayer;
}

- (AVPlayerLayer *)avPlayerLayer {
    if (!_avPlayerLayer) {
        self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        _avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _avPlayerLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _avPlayerLayer;
}

@end
