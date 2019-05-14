//
//  EVNetwork.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork.h"
#import "EVWebApi.h"
#import "EVLoginUserModel.h"

@import AFNetworking;

@interface EVNetwork ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation EVNetwork


- (void)resetAuthorizationHeader {
    if ([EVLoginUserModel sharedInstance].access_token) {
        [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[EVLoginUserModel sharedInstance].access_token] forHTTPHeaderField:@"Authorization"];
    } else {
        [self.sessionManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
}

- (void)resetRefreshAuthorizationHeader {
    if ([EVLoginUserModel sharedInstance].access_token) {
        [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[EVLoginUserModel sharedInstance].refresh_token] forHTTPHeaderField:@"Authorization"];
    } else {
        [self.sessionManager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
}

- (void)requestGetUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self resetAuthorizationHeader];
    [self.sessionManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",responseObject);
        NSNumber* errcode = [responseObject objectForKey:@"errCode"];
        if(errcode != nil && errcode.integerValue == 0){
            success(responseObject[@"data"]);
        } else if (errcode.integerValue < 0) {
            failed(responseObject[@"msg"]);
        } else {
            failed(responseObject[@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestPostUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self resetAuthorizationHeader];
    [self.sessionManager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        NSNumber* errcode = [responseObject objectForKey:@"errCode"];
        if(errcode != nil && errcode.integerValue == 0){
            success(responseObject[@"data"]);
        } else if (errcode.integerValue < 0) {
            failed(responseObject[@"msg"]);
        } else {
            failed(responseObject[@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestRefreshPostUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self resetRefreshAuthorizationHeader];
    [self.sessionManager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        NSNumber* errcode = [responseObject objectForKey:@"errCode"];
        if(errcode != nil && errcode.integerValue == 0){
            success(responseObject[@"data"]);
        } else if (errcode.integerValue < 0) {
            failed(responseObject[@"msg"]);
        } else {
            failed(responseObject[@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestPutUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self resetAuthorizationHeader];
    [self.sessionManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        NSNumber* errcode = [responseObject objectForKey:@"errCode"];
        if(errcode != nil && errcode.integerValue == 0){
            success(responseObject[@"data"]);
        } else if (errcode.integerValue < 0) {
            failed(responseObject[@"msg"]);
        } else {
            failed(responseObject[@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestDeleteUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self resetAuthorizationHeader];
    [self.sessionManager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        NSNumber* errcode = [responseObject objectForKey:@"errCode"];
        if(errcode != nil && errcode.integerValue == 0){
            success(responseObject[@"data"]);
        } else if (errcode.integerValue < 0) {
            failed(responseObject[@"msg"]);
        } else {
            failed(responseObject[@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

#pragma mark - LazyLoad
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        self.sessionManager =  [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:kEchoVideoHost]]; ;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
        _sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sessionManager.requestSerializer.timeoutInterval = 20;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [_sessionManager.requestSerializer setValue:version forHTTPHeaderField:@"App-Version"];
        [_sessionManager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"App-Type"];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [_sessionManager setSecurityPolicy:securityPolicy];
    }
    return _sessionManager;
}

@end
