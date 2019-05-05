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
@property (nonatomic, strong) UIView *currentPointView;

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
    [self addSubview:self.currentPointView];
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
    self.currentPointView.center = CGPointMake(CGRectGetMaxX(self.currentView.frame), self.currentView.center.y);
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
            CGFloat newCenterX = self.currentPointView.center.x+changedX;
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

- (UIView *)currentPointView {
    if (!_currentPointView) {
        CGFloat pointViewHeight = 30.f;
        CGFloat centerViewHeight = 10.f;
        self.currentPointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pointViewHeight, pointViewHeight)];
        _currentPointView.backgroundColor = [UIColor clearColor];
        
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake((pointViewHeight-centerViewHeight)/2.f, (pointViewHeight-centerViewHeight)/2.f, centerViewHeight, centerViewHeight)];
        centerView.backgroundColor = [UIColor redColor];
        centerView.layer.cornerRadius = centerViewHeight/2.f;
        [_currentPointView addSubview:centerView];
        
        CALayer * spreadLayer;
        spreadLayer = [CALayer layer];
        CGFloat diameter = centerViewHeight*2;  //扩散的大小
        spreadLayer.bounds = CGRectMake(0,0, diameter, diameter);
        spreadLayer.cornerRadius = diameter/2; //设置圆角变为圆形
        spreadLayer.position = CGPointMake(centerViewHeight/2.f, centerViewHeight/2.f);
        spreadLayer.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:.5].CGColor;
        [centerView.layer insertSublayer:spreadLayer below:centerView.layer];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_currentPointView addGestureRecognizer:panGesture];
    }
    return _currentPointView;
}

@end
