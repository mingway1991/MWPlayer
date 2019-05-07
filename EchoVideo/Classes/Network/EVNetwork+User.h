//
//  EVNetwork+User.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVNetwork (User)

/**
 登录
 
 @param username 用户名
 @param password 密码
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
             successBlock:(void(^)(void))successBlock
             failureBlock:(void(^)(NSString *msg))failureBlock;

/**
 刷新token
 
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)refreshTokenWithSuccessBlock:(void(^)(NSString *access_token, NSString *expired_date))successBlock
                        failureBlock:(void(^)(NSString *msg))failureBlock;

@end

NS_ASSUME_NONNULL_END
