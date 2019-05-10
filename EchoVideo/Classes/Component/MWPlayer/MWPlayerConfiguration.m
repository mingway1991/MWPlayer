//
//  MWPlayerConfiguration.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPlayerConfiguration.h"

@interface MWPlayerConfiguration ()

@property (nonatomic, assign, readwrite) int32_t timescale;

@end

@implementation MWPlayerConfiguration

+ (instancetype)defaultConfiguration {
    MWPlayerConfiguration *configuration = [[MWPlayerConfiguration alloc] init];
    configuration.loadingView = (UIView<MWPlayerLoadingProtocol> *)[[UIActivityIndicatorView alloc] init];
    configuration.topToolViewHeight = 50.f;
    configuration.bottomToolViewHeight = 50.f;
    configuration.bottomToolViewBackgroundColor = [UIColor blackColor];
    configuration.needLoop = NO;
    configuration.videoGravity = MWPlayerVideoGravityResizeAspect;
    configuration.needCoverView = YES;
    configuration.timescale = 600;
    return configuration;
}

@end
