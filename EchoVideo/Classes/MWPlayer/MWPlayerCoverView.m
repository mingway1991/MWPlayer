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
    MWPanDirectionLeftOrRight,
    MWPanDirectionUpOrDown,
} MWPanDirection;

static CGFloat kPlayerCoverBottomViewHeight = 50.f;

@interface MWPlayerCoverView () <UIGestureRecognizerDelegate> {
    MWPanDirection _panDirection;
    dispatch_source_t _hideTimer;
    BOOL _isVolume;
}

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
    [self addSubview:self.bottomView];
    [self addSubview:self.volumeView];
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

- (void)_horizontalMoved:(CGFloat)value {
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) { style = @"<<"; }//向左移动
    if (value > 0) { style = @">>"; }//向右移动
    if (value == 0) { return; }
    
}

- (void)_verticalMoved:(CGFloat)value {
    //通过三目运算符来判断显示音量还是亮度
    //关于音量界面不显示图标的问题,可以百度搜索BrightnessView这个类来解决
    _isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

#pragma mark -
#pragma mark Gesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    [self _showBottomView];
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
                _panDirection = MWPanDirectionLeftOrRight;
            } else if (x < y){ // 垂直移动
                // 音量和亮度
                _panDirection = MWPanDirectionUpOrDown;
                //判断移动的点在屏幕的哪个位置
                if (locationPoint.x <= self.frame.size.width / 2.0) {//以屏幕的1/2位分界线
                    //亮度,调节亮度
                    _isVolume = NO;
                } else {
                    //音量.调节音量
                    _isVolume = YES;
                }
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (_panDirection){//通过手势变量来判断是什么操作
                case MWPanDirectionUpOrDown:{//上下滑动
                    //音量和亮度
                    [self _verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                case MWPanDirectionLeftOrRight:{
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
                case MWPanDirectionUpOrDown:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    break;
                }
                case MWPanDirectionLeftOrRight:{
                    //水平
                    
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

//初始化一个音量界面
- (MPVolumeView *)volumeView {
    if (!_volumeView){
        self.volumeView = [[MPVolumeView alloc] init];
        _volumeView.hidden = YES;
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

@end
