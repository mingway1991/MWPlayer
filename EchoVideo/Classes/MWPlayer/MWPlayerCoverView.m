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

@import MediaPlayer;

typedef enum : NSUInteger {
    MWCoverViewPanDirectionLeftOrRight,
    MWCoverViewPanDirectionUpOrDown,
} MWCoverViewPanDirection; // 拖动方向

@interface MWPlayerCoverView () <UIGestureRecognizerDelegate> {
    MWCoverViewPanDirection _panDirection; // 拖动手势方向
    dispatch_source_t _hideTimer; // 隐藏工具条倒计时
    BOOL _isVolume; // 是否是修改音量
    BOOL _isShow; // 是否已经显示工具条
}

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) MWPlayerBottomView *bottomView;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UISlider *volumeViewSlider;

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
    [self _addTopView];
    [self addSubview:self.bottomView];
    [self addSubview:self.volumeView];
}

- (void)dealloc {
    NSLog(@"mwplayercoverview dealloc");
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self _updateTopViewFrame];
    [self _updateBottomViewFrame];
}

#pragma mark -
#pragma mark Setter
- (void)setInfo:(MWPlayerInfo *)info {
    _info = info;
    self.bottomView.info = info;
}

- (void)setConfiguration:(MWPlayerConfiguration *)configuration {
    [self _removeConfigurationPropertyObserver];
    _configuration = configuration;
    [self _addConfigurationPropertyObserver];
    [self _addTopView];
    [self _updateTopViewFrame];
    self.bottomView.backgroundColor = self.configuration.bottomToolViewBackgroundColor;
}

#pragma mark -
#pragma mark Observe Callback
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:kConfigurationTopToolViewKeyPath]) {
        [self _addTopView];
    } else if ([keyPath isEqualToString:kConfigurationTopToolViewHeightKeyPath]) {
        [self _updateTopViewFrame];
    } else if ([keyPath isEqualToString:kConfigurationBottomToolViewHeightKeyPath]) {
        [self _updateBottomViewFrame];
    } else if ([keyPath isEqualToString:kConfigurationBottomToolViewBackgroundColorKeyPath]) {
        self.bottomView.backgroundColor = self.configuration.bottomToolViewBackgroundColor;
    }
}

#pragma mark -
#pragma mark Observer
/* 添加configuration相关属性监听 */
- (void)_addConfigurationPropertyObserver {
    if (_configuration) {
        [_configuration addObserver:self forKeyPath:kConfigurationTopToolViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_configuration addObserver:self forKeyPath:kConfigurationTopToolViewHeightKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_configuration addObserver:self forKeyPath:kConfigurationBottomToolViewHeightKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [_configuration addObserver:self forKeyPath:kConfigurationBottomToolViewBackgroundColorKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

/* 移除configuration相关属性监听 */
- (void)_removeConfigurationPropertyObserver {
    if (_configuration) {
        [_configuration removeObserver:self forKeyPath:kConfigurationTopToolViewKeyPath];
        [_configuration removeObserver:self forKeyPath:kConfigurationTopToolViewHeightKeyPath];
        [_configuration removeObserver:self forKeyPath:kConfigurationBottomToolViewHeightKeyPath];
        [_configuration removeObserver:self forKeyPath:kConfigurationBottomToolViewBackgroundColorKeyPath];
    }
}

/* 清除监听 */
- (void)cleanObserver {
    [self _removeConfigurationPropertyObserver];
    [self.bottomView cleanObserver];
}

#pragma mark -
#pragma mark Public
- (void)show {
    [self _showView];
}

- (void)hide {
    [self _hideView];
}

#pragma mark -
#pragma mark Private
- (void)_hideView {
    [UIView animateWithDuration:.25f animations:^{
        MWSetMinY(self.bottomView, CGRectGetHeight(self.bounds));
        if (self.topView) {
            MWSetMinY(self.topView, -CGRectGetHeight(self.topView.bounds));
        }
    } completion:^(BOOL finished) {
        if (finished) {
            self->_isShow = NO;
        }
    }];
}

- (void)_showView {
    [UIView animateWithDuration:.25f animations:^{
        MWSetMinY(self.bottomView, CGRectGetHeight(self.bounds)-self.configuration.bottomToolViewHeight);
        if (self.topView) {
            MWSetMinY(self.topView, 0);
        }
    } completion:^(BOOL finished) {
        if (finished) {
            self->_isShow = YES;
            [self _countDownToHideView];
        }
    }];
}

/* 倒计时隐藏工具View */
- (void)_countDownToHideView {
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
                [self _hideView];
            });
        } else {
            time--;
        }
    });
    
    dispatch_resume(_hideTimer);
}

#pragma mark -
#pragma mark View
/* 添加顶部视图 */
- (void)_addTopView {
    if (self.topView) {
        [self.topView removeFromSuperview];
    }
    if (self.configuration.topToolView) {
        self.topView = self.configuration.topToolView;
        [self addSubview:self.topView];
        [self _updateTopViewFrame];
    }
}

/* 更新topView frame */
- (void)_updateTopViewFrame {
    _isShow = NO;
    if (self.configuration.topToolView) {
        self.configuration.topToolView.frame = CGRectMake(0, -self.configuration.topToolViewHeight, CGRectGetWidth(self.bounds), self.configuration.topToolViewHeight);
    }
}

/* 更新底部视图frame */
- (void)_updateBottomViewFrame {
    _isShow = NO;
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), self.configuration.bottomToolViewHeight);
}

#pragma mark -
#pragma mark Gesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    if (_isShow) {
        [self _hideView];
    } else {
        [self _showView];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint veloctyPoint = [pan velocityInView:self];
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 调节进度
                _panDirection = MWCoverViewPanDirectionLeftOrRight;
            } else if (x < y){ // 垂直移动
                // 音量和亮度
                _panDirection = MWCoverViewPanDirectionUpOrDown;
                // 判断移动的点在屏幕的哪个位置
                if (locationPoint.x <= self.frame.size.width / 2.0) { //以屏幕的1/2位分界线
                    // 亮度,调节亮度
                    _isVolume = NO;
                } else {
                    // 音量.调节音量
                    _isVolume = YES;
                }
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (_panDirection){ //通过手势变量来判断是什么操作
                case MWCoverViewPanDirectionUpOrDown:{ //上下滑动
                    //音量和亮度
                    [self _verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                case MWCoverViewPanDirectionLeftOrRight:{
                    [self _horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                default:
                    break;
            }
            break;
            
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            switch (_panDirection) {
                case MWCoverViewPanDirectionUpOrDown:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    break;
                }
                case MWCoverViewPanDirectionLeftOrRight:{
                    // 水平
                    break;
                }
                default:
                    break;
            }
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Pan Gesture
/* 横向移动 */
- (void)_horizontalMoved:(CGFloat)value {
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) {
        style = @"<<";
        self.info.panToPlayPercent = (self.info.currentTimeInterval-5)/self.info.totalTimeInterval;
    } else if (value > 0) {
        style = @">>";
        self.info.panToPlayPercent = (self.info.currentTimeInterval+5)/self.info.totalTimeInterval;
    }
    if (value == 0) { return; }
}

/* 竖向移动 */
- (void)_verticalMoved:(CGFloat)value {
    // 通过三目运算符来判断显示音量还是亮度
    // 关于音量界面不显示图标的问题,可以百度搜索BrightnessView这个类来解决
    _isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)bottomView {
    if (!_bottomView) {
        self.bottomView = [[MWPlayerBottomView alloc] init];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
    }
    return _bottomView;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        self.volumeView = [[MPVolumeView alloc] init];
        _volumeView.hidden = YES;
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]) {
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

@end
