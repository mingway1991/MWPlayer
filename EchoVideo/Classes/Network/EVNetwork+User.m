//
//  EVNetwork+User.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork+User.h"
#import "NSString+NSHash.h"
#import "EVWebApi.h"
#import "EVLoginUserModel.h"

@implementation EVNetwork (User)

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
             successBlock:(void(^)(void))successBlock
             failureBlock:(void(^)(NSString *msg))failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"password"] = [password MD5];
    [self requestPostUrl:kLoginApi Parameters:params Success:^(id result) {
        //保存用户信息
        [[EVLoginUserModel sharedInstance] modelSetWithJSON:result];
        [[EVLoginUserModel sharedInstance] save];
        successBlock();
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

- (void)refreshTokenWithSuccessBlock:(void(^)(NSString *access_token, NSString *expired_date))successBlock
                        failureBlock:(void(^)(NSString *msg))failureBlock {
    [self requestRefreshPostUrl:kRefreshApi Parameters:nil Success:^(id result) {
        if ([result[@"access_token"] length] > 0) {
            successBlock(result[@"access_token"],result[@"expired_date"]);
        } else {
            failureBlock(@"刷新token失败");
        }
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

@end
