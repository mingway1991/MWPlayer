//
//  EVNetwork+Video.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork+Video.h"
#import "EVWebApi.h"

@implementation EVNetwork (Video)

- (void)loadVideosWithAid:(NSNumber *)aid
                    after:(NSNumber *)after
                    count:(NSNumber *)count
             successBlock:(void(^)(NSArray<EVVideoModel *> *videos))successBlock
             failureBlock:(void(^)(NSString *msg))failureBlock {
    [self requestGetUrl:kVideosOfAlbumApi(aid) Parameters:@{@"after":after,@"count":count} Success:^(id result) {
        successBlock([NSArray modelArrayWithClass:[EVVideoModel class] json:result[@"videos"]]);
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

- (void)createVideoWithTitle:(NSString *)title
                   cover_url:(NSString * _Nullable)cover_url
                   video_url:(NSString *)video_url
                         aid:(NSNumber *)aid
                successBlock:(void(^)(void))successBlock
                failureBlock:(void(^)(NSString *msg))failureBlock {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    dict[@"title"] = title;
    dict[@"video_url"] = video_url;
    if (cover_url.length > 0) {
        dict[@"cover_url"] = cover_url;
    }
    [self requestPostUrl:kCreateVideoOfAlbumApi(aid) Parameters:dict Success:^(id result) {
        successBlock();
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

@end
