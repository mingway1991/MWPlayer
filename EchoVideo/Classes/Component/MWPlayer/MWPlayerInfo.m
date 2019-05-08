//
//  MWPlayerInfo.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPlayerInfo.h"

@implementation MWPlayerInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = MWPlayerStateInit;
        _totalTimeInterval = 0;
        _cacheTimeInterval = 0;
        _currentTimeInterval = 0;
        _direction = MWPlayerDirectionPortrait;
    }
    return self;
}

- (void)clear {
    _state = MWPlayerStateInit;
    _cacheTimeInterval = 0;
    _currentTimeInterval = 0;
    _totalTimeInterval = 0;
    _panToPlayPercent = 0;
    _errMessage = nil;
}

@end
