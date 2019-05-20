//
//  EVLoginViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVLoginViewController.h"
#import "Constant.h"
#import "UIColor+MWUtil.h"
#import "EVNetwork+User.h"
#import "EVLoadingHelper.h"

@interface EVLoginViewController ()

@property (nonatomic, strong) UITextField *usernameTextFiled;
@property (nonatomic, strong) UITextField *passwordTextFiled;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) EVNetwork *network;

@end

@implementation EVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    [self initUI];
}

- (void)initUI {
    [self.view addSubview:self.usernameTextFiled];
    [self.view addSubview:self.passwordTextFiled];
    [self.view addSubview:self.loginButton];
}

#pragma mark -
#pragma mark Request
- (void)loginAction {
    [self.usernameTextFiled resignFirstResponder];
    [self.passwordTextFiled resignFirstResponder];
    if (self.usernameTextFiled.text.length == 0) {
        return;
    }
    if (self.passwordTextFiled.text.length == 0) {
        return;
    }
    EVLoadingHelper *helper = [[EVLoadingHelper alloc] init];
    [helper showLoadingHUDAddedToView:self.view text:@"加载中..."];
    [self.network loginWithUsername:self.usernameTextFiled.text password:self.passwordTextFiled.text successBlock:^{
        [helper hideLoadingHUD];
        [[NSNotificationCenter defaultCenter] postNotificationName:SWITCH_HOME_NOTIFICATION_NAME object:nil];
    } failureBlock:^(NSString * _Nonnull msg) {
        [helper hideLoadingHUD];
    }];
}

#pragma mark -
#pragma mark LazyLoad
- (UITextField *)usernameTextFiled {
    if (!_usernameTextFiled) {
        self.usernameTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_RIGHT_MARGIN, MWTopBarHeight+20.f, MWScreenWidth-2*LEFT_RIGHT_MARGIN, 40.f)];
        _usernameTextFiled.placeholder = @"用户名";
        _usernameTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_usernameTextFiled.bounds)-.5f, CGRectGetWidth(_usernameTextFiled.bounds), .5f)];
        line.backgroundColor = [UIColor mw_colorWithHexString:BOTTOM_LINE_COLOR];
        [_usernameTextFiled addSubview:line];
    }
    return _usernameTextFiled;
}

- (UITextField *)passwordTextFiled {
    if (!_passwordTextFiled) {
        self.passwordTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.usernameTextFiled.frame), CGRectGetMaxY(self.usernameTextFiled.frame)+10.f, CGRectGetWidth(self.usernameTextFiled.frame), CGRectGetHeight(self.usernameTextFiled.frame))];
        _passwordTextFiled.placeholder = @"密码";
        _passwordTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextFiled.secureTextEntry = YES;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_passwordTextFiled.bounds)-.5f, CGRectGetWidth(_passwordTextFiled.bounds), .5f)];
        line.backgroundColor = [UIColor mw_colorWithHexString:BOTTOM_LINE_COLOR];
        [_passwordTextFiled addSubview:line];
    }
    return _passwordTextFiled;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.frame = CGRectMake(LEFT_RIGHT_MARGIN, CGRectGetMaxY(self.passwordTextFiled.frame)+50.f, MWScreenWidth-2*LEFT_RIGHT_MARGIN, 50.f);
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor mw_colorWithHexString:THEME_COLOR];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (EVNetwork *)network {
    if (!_network) {
        self.network = [[EVNetwork alloc] init];
    }
    return _network;
}

@end
