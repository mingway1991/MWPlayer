//
//  EVNetwork.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVNetwork : NSObject

- (void)resetAuthorizationHeader;

- (void)resetRefreshAuthorizationHeader;

- (void)requestGetUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestPostUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestRefreshPostUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestPutUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestDeleteUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;

@end

NS_ASSUME_NONNULL_END
