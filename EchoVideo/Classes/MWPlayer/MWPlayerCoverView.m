//
//  MWPlayerCoverView.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPlayerCoverView.h"
#import "MWPlayerBottomView.h"
#import "MWDefines.h"

static CGFloat kPlayerCoverBottomViewHeight = 50.f;

@interface MWPlayerCoverView () {
    dispatch_source_t _hideTimer;
}

@property (nonatomic, strong) MWPlayerBottomView *bottomView;

@end

@implementation MWPlayerCoverView

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
    [self addSubview:self.bottomView];
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), kPlayerCoverBottomViewHeight);
}

#pragma mark -
#pragma mark Setter
- (void)setInfo:(MWPlayerInfo *)info {
    _info = info;
    
    self.bottomView.info = info;
}

#pragma mark -
#pragma mark Public
- (void)show {
    [self _showBottomView];
}

- (void)hide {
    [self _hideBottomView];
}

#pragma mark -
#pragma mark Private
- (void)_hideBottomView {
    [UIView animateWithDuration:.25f animations:^{
        MWSetMinY(self.bottomView, CGRectGetHeight(self.bounds));
    }];
}

- (void)_showBottomView {
    [UIView animateWithDuration:.25f animations:^{
        MWSetMinY(self.bottomView, CGRectGetHeight(self.bounds)-kPlayerCoverBottomViewHeight);
    } completion:^(BOOL finished) {
        if (finished) {
            [self _countDownToHideBottomView];
        }
    }];
}

- (void)_countDownToHideBottomView {
    if (_hideTimer) {
        dispatch_source_cancel(self->_hideTimer);
        _hideTimer = nil;
    }
    __block NSInteger time = 5.f;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _hideTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_hideTimer,DISPATCH_TIME_NOW,1.0*NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_hideTimer, ^{
        if (time <= 0) {
            dispatch_source_cancel(self->_hideTimer);
            self->_hideTimer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _hideBottomView];
            });
        } else {
            time--;
        }
    });
    
    dispatch_resume(_hideTimer);
}

#pragma mark -
#pragma mark Gesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    [self _showBottomView];
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)bottomView {
    if (!_bottomView) {
        self.bottomView = [[MWPlayerBottomView alloc] init];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGesture];
    }
    return _bottomView;
}

@end
