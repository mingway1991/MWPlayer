//
//  MWPlayerConfiguration.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPlayerLoadingProtocol.h"

// kvo使用
static NSString *kConfigurationLoadingViewKeyPath = @"loadingView";
static NSString *kConfigurationTopToolViewKeyPath = @"topToolView";
static NSString *kConfigurationTopToolViewHeightKeyPath = @"topToolViewHeight";
static NSString *kConfigurationBottomToolViewHeightKeyPath = @"bottomToolViewHeight";
static NSString *kConfigurationBottomToolViewBackgroundColorKeyPath = @"bottomToolViewBackgroundColor";

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerConfiguration : NSObject

@property (nonatomic, strong) UIView<MWPlayerLoadingProtocol> *loadingView; // 加载指示器，默认使用系统UIActivityIndicatorView
@property (nonatomic, strong, nullable) UIView *topToolView; // 顶部工具view，默认空
@property (nonatomic, assign) CGFloat topToolViewHeight; // 底部工具视图高度，默认50
@property (nonatomic, assign) CGFloat bottomToolViewHeight; // 底部工具视图高度，默认50
@property (nonatomic, strong) UIColor *bottomToolViewBackgroundColor; // 底部工具视图背景色，默认黑色

+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END