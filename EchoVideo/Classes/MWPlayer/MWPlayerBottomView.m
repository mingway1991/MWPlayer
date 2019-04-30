//
//  MWPlayerBottomView.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPlayerBottomView.h"
#import "MWDefines.h"
#import "MWPlayerProgressView.h"

static CGFloat kCoverViewBottomHeight = 30.f;

@interface MWPlayerBottomView () <MWPlayerProgressViewDelegate>

@property (nonatomic, strong) UIButton *playOrPauseButton;
@property (nonatomic, strong) MWPlayerProgressView *progressView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *fullScreenButton;

@end

@implementation MWPlayerBottomView

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
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.playOrPauseButton];
    [self addSubview:self.durationLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.fullScreenButton];
}

- (void)dealloc {
    if (_info) {
        [self _removeObserver];
    }
}

#pragma mark -
#pragma mark Setter
- (void)setInfo:(MWPlayerInfo *)info {
    if (_info) {
        [self _removeObserver];
    }
    _info = info;
    [self _addObserver];
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playOrPauseButton.frame = CGRectMake(10.f, (CGRectGetHeight(self.bounds)-kCoverViewBottomHeight)/2.f, kCoverViewBottomHeight, kCoverViewBottomHeight);
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-10-kCoverViewBottomHeight, CGRectGetMinX(self.playOrPauseButton.frame), kCoverViewBottomHeight, kCoverViewBottomHeight);
    [self _updateDurationLabel];
    [self _updateProgressViewFrame];
}

#pragma mark -
#pragma mark Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kStateKeyPath]) {
        BOOL isPlaying = self.info.state == MWPlayerStatePlaying;
        [self.playOrPauseButton setSelected:!isPlaying];
    } else if ([keyPath isEqualToString:kTotalTimeIntervalKeyPath]) {
        self.progressView.totalTimeInterval = self.info.totalTimeInterval;
        [self _updateDurationLabel];
    } else if ([keyPath isEqualToString:kCacheTimeIntervalKeyPath]) {
        self.progressView.cacheTimeInterval = self.info.cacheTimeInterval;
    } else if ([keyPath isEqualToString:kCurrentTimeIntervalKeyPath]) {
        self.progressView.currentTimeInterval = self.info.currentTimeInterval;
        [self _updateDurationLabel];
    }
}

static CGFloat durationWidth = 0;

#pragma mark -
#pragma mark Private
- (void)_updateDurationLabel {
    NSString *durationText = [NSString stringWithFormat:@"%@/%@", [self _formatPlayTime:self.info.currentTimeInterval], [self _formatPlayTime:self.info.totalTimeInterval]];
    self.durationLabel.text = durationText;
    
    CGFloat textWidth = [durationText boundingRectWithSize:CGSizeMake(MAXFLOAT, kCoverViewBottomHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.durationLabel.font} context:nil].size.width+5.f;
    if (textWidth > durationWidth) {
        durationWidth = textWidth;
    }
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.playOrPauseButton.frame) +10.f, CGRectGetMinY(self.playOrPauseButton.frame), durationWidth, kCoverViewBottomHeight);
}

- (void)_updateProgressViewFrame {
    CGFloat minX = CGRectGetMaxX(self.durationLabel.frame)+10.f;
    self.progressView.frame = CGRectMake(minX, CGRectGetMinY(self.playOrPauseButton.frame), CGRectGetMinX(self.fullScreenButton.frame)-10.f-minX, kCoverViewBottomHeight);
}

- (NSString *)_formatPlayTime:(NSTimeInterval)duration {
    int minute = 0, hour = 0, secend = duration;
    minute = (secend % 3600)/60;
    hour = secend / 3600;
    secend = secend % 60;
    if (hour == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minute, secend];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secend];
    }
}

- (void)_removeObserver {
    [_info removeObserver:self forKeyPath:kStateKeyPath];
    [_info removeObserver:self forKeyPath:kTotalTimeIntervalKeyPath];
    [_info removeObserver:self forKeyPath:kCacheTimeIntervalKeyPath];
    [_info removeObserver:self forKeyPath:kCurrentTimeIntervalKeyPath];
}

- (void)_addObserver {
    [_info addObserver:self forKeyPath:kStateKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_info addObserver:self forKeyPath:kTotalTimeIntervalKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_info addObserver:self forKeyPath:kCacheTimeIntervalKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_info addObserver:self forKeyPath:kCurrentTimeIntervalKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -
#pragma mark Actions
- (void)clickPlayOrPauseButton:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    self.info.state = self.info.state == MWPlayerStatePlaying ? MWPlayerStatePause : MWPlayerStatePlaying;
}

- (void)clickFullScreenButton:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if (sender.isSelected) {
        self.info.direction = MWPlayerDirectionLandscapeLeft;
    } else {
        self.info.direction = MWPlayerDirectionPortrait;
    }
}

#pragma mark -
#pragma mark MWPlayerProgressViewDelegate
- (void)progressViewBeginPanProgress:(MWPlayerProgressView *)progressView {
    self.info.state = MWPlayerStatePause;
}

- (void)progressViewHandlePanProgress:(MWPlayerProgressView *)progressView
                              percent:(float)percent {
    self.info.panToPlayPercent = percent;
}

- (void)progressViewEndPanProgress:(MWPlayerProgressView *)progressView {
    self.info.state = MWPlayerStatePlaying;
}

#pragma mark -
#pragma mark LazyLoad
- (UIButton *)playOrPauseButton {
    if (!_playOrPauseButton) {
        self.playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton addTarget:self action:@selector(clickPlayOrPauseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    }
    return _playOrPauseButton;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        self.durationLabel = [[UILabel alloc] init];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.font = [UIFont systemFontOfSize:12.f];
        _durationLabel.textColor = [UIColor whiteColor];
    }
    return _durationLabel;
}

- (MWPlayerProgressView *)progressView {
    if (!_progressView) {
        self.progressView = [[MWPlayerProgressView alloc] init];
        _progressView.delegate = self;
    }
    return _progressView;
}

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"zoom_out"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"zoom_in"] forState:UIControlStateSelected];
        [_fullScreenButton setImageEdgeInsets:UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f)];
        [_fullScreenButton addTarget:self action:@selector(clickFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

@end
