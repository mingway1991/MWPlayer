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

static NSString *kAVPlaterLoadedTimeRangesKeyPath = @"loadedTimeRanges";
static NSString *kAVPlaterStatusKeyPath = @"status";

@import AVFoundation;

@interface MWPlayerView () {
    UIView *_superView;
    CGRect _originFrame;
}

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) MWPlayerCoverView *coverView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) MWPlayerInfo *info;
@property (nonatomic, strong) CADisplayLink *displayLink;

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
    
    self.info = [[MWPlayerInfo alloc] init];
    self.coverView.info = self.info;
    [self.info addObserver:self forKeyPath:kStateKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.info addObserver:self forKeyPath:kPanToPlayPercentKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.info addObserver:self forKeyPath:kDirectionKeyPath options:NSKeyValueObservingOptionNew context:nil];
    
    self.info.state = MWPlayerStateInit;
    self.backgroundColor = [UIColor blackColor];
    
    [self.layer addSublayer:self.avPlayerLayer];
    [self addSubview:self.indicatorView];
    [self addSubview:self.coverView];
    
    __weak __typeof(self) weakSelf = self;
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval current = CMTimeGetSeconds(time);
        NSTimeInterval total = CMTimeGetSeconds(weakSelf.avPlayer.currentItem.duration);
        if (current > total || total <= 0 || total != total || current != current) {
            current = 0;
            total = 0;
        }
        weakSelf.info.totalTimeInterval = total;
        weakSelf.info.currentTimeInterval = current;
    }];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_upadteLoading)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)dealloc {
    [_info removeObserver:self forKeyPath:kStateKeyPath];
    [_info removeObserver:self forKeyPath:kPanToPlayPercentKeyPath];
    [_info removeObserver:self forKeyPath:kDirectionKeyPath];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    self.info.videoUrl = videoUrl;
    if (self.avPlayer && self.avPlayer.currentItem) {
        [self.avPlayer.currentItem removeObserver:self forKeyPath:kAVPlaterLoadedTimeRangesKeyPath];
        [self.avPlayer.currentItem removeObserver:self forKeyPath:kAVPlaterStatusKeyPath];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    if (self.avPlayer && videoUrl.length > 0) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];
        [playerItem addObserver:self forKeyPath:kAVPlaterLoadedTimeRangesKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:kAVPlaterStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];
    }
}

#pragma mark -
#pragma mark Public
- (void)play {
    self.info.state = MWPlayerStatePlaying;
}

- (void)pause {
    self.info.state = MWPlayerStatePause;
}

- (void)pointToPlay:(float)percent {
    [self _changeProgressWithPercent:percent];
    self.info.state = MWPlayerStatePlaying;
}

#pragma mark -
#pragma mark Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:kAVPlaterLoadedTimeRangesKeyPath]){
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
        NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval cache = startSeconds + durationSeconds;
        NSTimeInterval total = CMTimeGetSeconds(playerItem.duration);
        self.info.totalTimeInterval = total;
        self.info.cacheTimeInterval = cache;
        
    } else if ([keyPath isEqualToString:kAVPlaterStatusKeyPath]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"playerItem is ready");
        } else{
            NSLog(@"load break");
        }
    } else if ([keyPath isEqualToString:kStateKeyPath]) {
        if (self.info.state == MWPlayerStatePlaying) {
            [self _play];
        } else if (self.info.state == MWPlayerStatePause) {
            [self _pause];
        } else if (self.info.state == MWPlayerStatePlayFinished) {
            [self _changeProgressWithPercent:0];
        }
    } else if ([keyPath isEqualToString:kPanToPlayPercentKeyPath]) {
        [self _changeProgressWithPercent:self.info.panToPlayPercent];
    } else if ([keyPath isEqualToString:kDirectionKeyPath]) {
        if (self.info.direction == MWPlayerDirectionPortrait) {
            [self _zoomOut];
        } else {
            [self _zoomInWithDirection:self.info.direction];
        }
    }
}

- (void)playbackFinished:(NSNotification *)notification {
    self.info.state = MWPlayerStatePlayFinished;
}

#pragma mark -
#pragma mark Private
- (void)_play {
    [self.avPlayer play];
    [self.coverView show];
}

- (void)_pause {
    [self.avPlayer pause];
    [self.coverView show];
}

- (void)_changeProgressWithPercent:(float)percent {
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval duration = percent * CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
            
        }];
    }
}

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

- (void)_zoomOut {
    self.frame = _originFrame;
    [_superView addSubview:self];
    [self.avPlayerLayer setAffineTransform:CGAffineTransformIdentity];
    [self.coverView.layer setAffineTransform:CGAffineTransformIdentity];
}

- (void)_upadteLoading {
    NSTimeInterval current = CMTimeGetSeconds(self.avPlayer.currentTime);
    if (current != self.info.currentTimeInterval) {
        [self.indicatorView stopAnimating];
    } else {
        [self.indicatorView startAnimating];
    }
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
        self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.avPlayerLayer.contentsScale = [UIScreen mainScreen].scale;
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
