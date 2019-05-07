//
//  EVLoginUserModel.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVUserModel.h"

@import YYKit;

typedef enum {
    TokenValid = 0,
    TokenNeedRefresh = 1,
    TokenExpired
} TokenStatus;
NS_ASSUME_NONNULL_BEGIN

@interface EVLoginUserModel : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, copy) NSString *expired_date;
@property (nonatomic, copy) NSString *refresh_token;

@property (nonatomic, strong) EVUserModel *user;

+ (EVLoginUserModel *)sharedInstance;

- (TokenStatus)verifyTokenValid;

- (void)save;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
