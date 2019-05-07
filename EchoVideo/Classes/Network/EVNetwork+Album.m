//
//  EVNetwork+Album.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork+Album.h"
#import "EVWebApi.h"

@implementation EVNetwork (Album)

- (void)loadAlbumsWithSuccessBlock:(void(^)(NSArray<EVAlbumModel *> *albums))successBlock
                      failureBlock:(void(^)(NSString *msg))failureBlock {
    [self requestGetUrl:kAlbumsApi Parameters:nil Success:^(id result) {
        successBlock([NSArray modelArrayWithClass:[EVAlbumModel class] json:result[@"albums"]]);
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

@end
