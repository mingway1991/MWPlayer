//
//  EVNetwork+Album.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork.h"
#import "EVAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVNetwork (Album)

/**
 获取专辑列表
 
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)loadAlbumsWithSuccessBlock:(void(^)(NSArray<EVAlbumModel *> *albums))successBlock
                      failureBlock:(void(^)(NSString *msg))failureBlock;

@end

NS_ASSUME_NONNULL_END
