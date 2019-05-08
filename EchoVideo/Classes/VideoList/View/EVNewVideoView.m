//
//  EVNewVideoView.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNewVideoView.h"
#import "MWDefines.h"
#import "Constant.h"
#import "UIColor+MWUtil.h"

@interface EVNewVideoView ()

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *createButton;

@end

@implementation EVNewVideoView

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
    [self addSubview:self.shadowView];
    [self addSubview:self.centerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shadowView.frame = self.bounds;
    CGFloat leftAndRight = 20.f;
    CGFloat height = 200.f;
    self.centerView.frame = CGRectMake(leftAndRight, MWTopBarHeight+60.f, CGRectGetWidth(self.bounds)-2*leftAndRight, height);
    self.titleTextField.frame = CGRectMake(LEFT_RIGHT_MARGIN, 20.f, CGRectGetWidth(self.centerView.frame)-2*LEFT_RIGHT_MARGIN, 40.f);
    self.urlTextField.frame = CGRectMake(CGRectGetMinX(self.titleTextField.frame), CGRectGetMaxY(self.titleTextField.frame)+10.f, CGRectGetWidth(self.titleTextField.frame), CGRectGetHeight(self.titleTextField.frame));
    self.createButton.frame = CGRectMake(LEFT_RIGHT_MARGIN, CGRectGetMaxY(self.urlTextField.frame)+30.f, CGRectGetWidth(self.centerView.frame)-2*LEFT_RIGHT_MARGIN, 40.f);
}

#pragma mark -
#pragma mark Public
- (void)show {
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
}

- (void)hide {
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark Action
- (void)createAction {
    if (self.titleTextField.text.length == 0) {
        return;
    }
    if (self.urlTextField.text.length == 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(newVideoView:title:url:)]) {
        [self.delegate newVideoView:self title:self.titleTextField.text url:self.urlTextField.text];
    }
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)shadowView {
    if (!_shadowView) {
        self.shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.5];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_shadowView addGestureRecognizer:tap];
    }
    return _shadowView;
}

- (UIView *)centerView {
    if (!_centerView) {
        self.centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor whiteColor];
        [_centerView addSubview:self.titleTextField];
        [_centerView addSubview:self.urlTextField];
        [_centerView addSubview:self.createButton];
    }
    return _centerView;
}

- (UITextField *)titleTextField {
    if (!_titleTextField) {
        self.titleTextField = [[UITextField alloc] init];
        _titleTextField.placeholder = @"请输入标题";
        _titleTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _titleTextField;
}

- (UITextField *)urlTextField {
    if (!_urlTextField) {
        self.urlTextField = [[UITextField alloc] init];
        _urlTextField.placeholder = @"请输入视频地址";
        _urlTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _urlTextField;
}

- (UIButton *)createButton {
    if (!_createButton) {
        self.createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createButton setTitle:@"创建" forState:UIControlStateNormal];
        _createButton.backgroundColor = [UIColor mw_colorWithHexString:THEME_COLOR];
        [_createButton addTarget:self action:@selector(createAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createButton;
}

@end