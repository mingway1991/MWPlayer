//
//  MWPlayerProgressView.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPlayerProgressView.h"
#import "MWDefines.h"

static CGFloat kProgressHeight = 2.f;

@interface MWPlayerProgressView ()

@property (nonatomic, strong) UIView *totalView;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, strong) UIView *cacheView;
@property (nonatomic, strong) UIButton *currentButton;

@end

@implementation MWPlayerProgressView

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
    self.totalTimeInterval = 0;
    self.cacheTimeInterval = 0;
    self.currentTimeInterval = 0;
    
    [self addSubview:self.totalView];
    [self addSubview:self.cacheView];
    [self addSubview:self.currentView];
    [self addSubview:self.currentButton];
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    self.totalView.frame = CGRectMake(0, (CGRectGetHeight(self.bounds)-kProgressHeight)/2.f, CGRectGetWidth(self.bounds), kProgressHeight);
    [self _updateCacheViewFrame];
    [self _updateCurrentFrame];
}

#pragma mark -
#pragma mark Setter
- (void)setTotalTimeInterval:(NSTimeInterval)totalTimeInterval {
    _totalTimeInterval = totalTimeInterval;
}

- (void)setCacheTimeInterval:(NSTimeInterval)cacheTimeInterval {
    _cacheTimeInterval = cacheTimeInterval;
    
    [self _updateCacheViewFrame];
}

- (void)setCurrentTimeInterval:(NSTimeInterval)currentTimeInterval {
    _currentTimeInterval = currentTimeInterval;
    
    [self _updateCurrentFrame];
}

#pragma mark -
#pragma mark Private
- (void)_updateCacheViewFrame {
    self.cacheView.frame = CGRectMake(0, (CGRectGetHeight(self.bounds)-kProgressHeight)/2.f, self.totalTimeInterval == 0 ? 0 : CGRectGetWidth(self.bounds) * (self.cacheTimeInterval/self.totalTimeInterval), kProgressHeight);
}

- (void)_updateCurrentFrame {
   self.currentView.frame = CGRectMake(0, (CGRectGetHeight(self.bounds)-kProgressHeight)/2.f, self.totalTimeInterval == 0 ? 0 : CGRectGetWidth(self.bounds) * (self.currentTimeInterval/self.totalTimeInterval), kProgressHeight);
    
    CGFloat currentButtonHeight = 10.f;
    self.currentButton.frame = CGRectMake(0, 0, currentButtonHeight, currentButtonHeight);
    self.currentButton.center = CGPointMake(CGRectGetMaxX(self.currentView.frame), self.currentView.center.y);
}

#pragma mark -
#pragma mark Gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if ([self.delegate respondsToSelector:@selector(progressViewBeginPanProgress:)]) {
                [self.delegate progressViewBeginPanProgress:self];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint transP = [panGesture translationInView:panGesture.view];
            CGFloat changedX = transP.x;
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
            CGFloat newCenterX = self.currentButton.center.x+changedX;
            if (newCenterX >= 0 && newCenterX <= CGRectGetWidth(self.totalView.bounds)) {
                CGFloat currentWidth = newCenterX;
                CGFloat totalWidth = CGRectGetWidth(self.totalView.bounds);
                self.currentTimeInterval = self.totalTimeInterval*(currentWidth/totalWidth);
                if ([self.delegate respondsToSelector:@selector(progressViewHandlePanProgress:percent:)]) {
                    [self.delegate progressViewHandlePanProgress:self percent:currentWidth/totalWidth];
                }
            }
            break;
        }
        default: {
            if ([self.delegate respondsToSelector:@selector(progressViewEndPanProgress:)]) {
                [self.delegate progressViewEndPanProgress:self];
            }
            break;
        }
    }
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)totalView {
    if (!_totalView) {
        self.totalView = [[UIView alloc] init];
        _totalView.backgroundColor = [UIColor whiteColor];
    }
    return _totalView;
}

- (UIView *)cacheView {
    if (!_cacheView) {
        self.cacheView = [[UIView alloc] init];
        _cacheView.backgroundColor = [UIColor lightGrayColor];
    }
    return _cacheView;
}

- (UIView *)currentView {
    if (!_currentView) {
        self.currentView = [[UIView alloc] init];
        _currentView.backgroundColor = [UIColor redColor];
    }
    return _currentView;
}

- (UIButton *)currentButton {
    if (!_currentButton) {
        self.currentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _currentButton.backgroundColor = [UIColor redColor];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_currentButton addGestureRecognizer:panGesture];
    }
    return _currentButton;
}

@end
