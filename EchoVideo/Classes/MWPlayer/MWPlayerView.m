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
static NSString *kAvPlaterPlaybackBufferEmptyKeyPath = @"playbackBufferEmpty";

@import AVFoundation;

@interface MWPlayerView () {
    UIView *_superView; // 保存父视图，便于全屏后恢复
    CGRect _originFrame; // 保存原始frame，便于全屏后恢复
}

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;

@property (nonatomic, strong) MWPlayerCoverView *coverView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) MWPlayerInfo *info;
@property (nonatomic, strong) CADisplayLink *loadingDisplayLink;

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
    
    self.info = [[MWPlayerInfo alloc] init];
    self.coverView.info = self.info;
    
    [self _addPropertyObserver];
    
    self.info.state = MWPlayerStateInit;
    
    __weak __typeof(self) weakSelf = self;
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
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
    
    self.loadingDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_upadteLoading)];
    [self.loadingDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.layer addSublayer:self.avPlayerLayer];
    [self addSubview:self.indicatorView];
    [self addSubview:self.coverView];
}

- (void)dealloc {
    NSLog(@"mwplayerview dealloc");
    
    [_loadingDisplayLink invalidate];
    _loadingDisplayLink = nil;
    
    [self _releasePropertyObserver];
    _info = nil;
    
    [self _releaseCurrentAvPlayerItemObserver];
    [_avPlayer removeTimeObserver:self];
    _avPlayer = nil;
    
    [_avPlayerLayer removeFromSuperlayer];
    _avPlayerLayer = nil;
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.avPlayerLayer.frame = self.bounds;
    self.coverView.frame = self.bounds;
    self.indicatorView.frame = self.bounds;
}

#pragma mark -
#pragma mark Setter
- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    [self _releaseCurrentAvPlayerItemObserver];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];
    [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
    
    [self _addCurrentAvPlayerItemObserver];
    
    self.info.videoUrl = videoUrl;
}

#pragma mark -
#pragma mark Public
- (void)play {
    self.info.state = MWPlayerStatePrepareToPlay;
}

- (void)pause {
    self.info.state = MWPlayerStatePause;
}

- (void)pointToPlay:(float)percent {
    [self _changeProgressWithPercent:percent];
    self.info.state = MWPlayerStatePrepareToPlay;
}

- (void)stop {
    self.info.state = MWPlayerStateStop;
}

#pragma mark -
#pragma mark Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:kAvPlaterStatusKeyPath]){
        // avplaer load status
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"playerItem is ready");
        } else{
            NSLog(@"load break");
        }
    } else if ([keyPath isEqualToString:kAvPlaterLoadedTimeRangesKeyPath]){
        // avplayer buffer
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
        NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval cache = startSeconds + durationSeconds;
        NSTimeInterval total = CMTimeGetSeconds(playerItem.duration);
        self.info.totalTimeInterval = total;
        self.info.cacheTimeInterval = cache;
    } else if ([keyPath isEqualToString:kAvPlaterPlaybackBufferEmptyKeyPath]){
        // avplaer playback buffer empty
        
    } else if ([keyPath isEqualToString:kStateKeyPath]) {
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
            [self _changeProgressWithPercent:0];
        }
    } else if ([keyPath isEqualToString:kPanToPlayPercentKeyPath]) {
        // 更改播放进度
        [self _changeProgressWithPercent:self.info.panToPlayPercent];
    } else if ([keyPath isEqualToString:kDirectionKeyPath]) {
        // 更改播放器方向
        if (self.info.direction == MWPlayerDirectionPortrait) {
            [self _zoomOut];
        } else {
            [self _zoomInWithDirection:self.info.direction];
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
    [self.avPlayer pause];
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
    [self _changeProgressWithPercent:0];
    [self.avPlayer pause];
    [self.coverView show];
}

/* 拖动进度条 */
- (void)_changeProgressWithPercent:(float)percent {
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval duration = percent * CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
            
        }];
    }
}

/* 更新loading状态 */
- (void)_upadteLoading {
    if (self.info.state == MWPlayerStatePrepareToPlay) {
        // 准备播放状态默认显示加载中
        [self.indicatorView startAnimating];
    } else if (self.info.state == MWPlayerStatePlaying) {
        // 播放状态下，判断是否处于加载中状态
        NSTimeInterval current = CMTimeGetSeconds(self.avPlayer.currentTime);
        if (current != self.info.currentTimeInterval) {
            [self.indicatorView stopAnimating];
        } else {
            [self.indicatorView startAnimating];
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
        [self.avPlayerLayer setAffineTransform:CGAffineTransformMakeRotation(degreeToRadian(90))];
        [self.coverView.layer setAffineTransform:CGAffineTransformMakeRotation(degreeToRadian(90))];
    } else if (direction == MWPlayerDirectionLandscapeRight) {
        [self.avPlayerLayer setAffineTransform:CGAffineTransformMakeRotation(degreeToRadian(-90))];
        [self.coverView.layer setAffineTransform:CGAffineTransformMakeRotation(degreeToRadian(-90))];
    }
}

/* 缩小窗口 */
- (void)_zoomOut {
    self.frame = _originFrame;
    [_superView addSubview:self];
    [self.avPlayerLayer setAffineTransform:CGAffineTransformIdentity];
    [self.coverView.layer setAffineTransform:CGAffineTransformIdentity];
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

/* 取消属性监听 */
- (void)_releasePropertyObserver {
    [_info removeObserver:self forKeyPath:kStateKeyPath];
    [_info removeObserver:self forKeyPath:kPanToPlayPercentKeyPath];
    [_info removeObserver:self forKeyPath:kDirectionKeyPath];
}

/* 添加属性监听 */
- (void)_addPropertyObserver {
    [_info addObserver:self forKeyPath:kStateKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_info addObserver:self forKeyPath:kPanToPlayPercentKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_info addObserver:self forKeyPath:kDirectionKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -
#pragma mark LazyLoad
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

- (MWPlayerCoverView *)coverView {
    if (!_coverView) {
        self.coverView = [[MWPlayerCoverView alloc] init];
    }
    return _coverView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        self.indicatorView = [[UIActivityIndicatorView alloc] init];
    }
    return _indicatorView;
}

@end
