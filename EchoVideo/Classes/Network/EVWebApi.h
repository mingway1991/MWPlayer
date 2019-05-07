//
//  EVWebApi.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kEchoVideoHost @"http://127.0.0.1:8085"

#define kLoginApi @"/v1/login"
#define kRefreshApi @"/v1/refresh"
#define kLogoutApi @"/v1/logout"
#define kRegisterApi @"/v1/users"

#define kAlbumsApi @"/v1/albums"

#define kVideosOfAlbumApi(aid) [NSString stringWithFormat:@"/v1/albums/%@/videos",aid]
#define kCreateVideoOfAlbumApi(aid) [NSString stringWithFormat:@"/v1/albums/%@/videos",aid]


NS_ASSUME_NONNULL_END
