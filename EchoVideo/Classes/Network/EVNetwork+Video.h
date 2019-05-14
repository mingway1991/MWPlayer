//
//  EVNetwork+Video.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork.h"
#import "EVVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVNetwork (Video)

/**
 获取视频列表
 
 @param aid 专辑id
 @param after after
 @param count count
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)loadVideosWithAid:(NSNumber *)aid
                    after:(NSNumber *)after
                    count:(NSNumber *)count
             successBlock:(void(^)(NSArray<EVVideoModel *> *videos))successBlock
             failureBlock:(void(^)(NSString *msg))failureBlock;

/**
 创建视频
 
 @param title 标题
 @param cover_url 封面
 @param video_url 视频地址
 @param aid 专辑id
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)createVideoWithTitle:(NSString *)title
                   cover_url:(NSString * _Nullable)cover_url
                   video_url:(NSString *)video_url
                         aid:(NSNumber *)aid
                successBlock:(void(^)(void))successBlock
                failureBlock:(void(^)(NSString *msg))failureBlock;

/**
 删除视频
 
 @param aid 专辑id
 @param vid 视频id
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)deleteVideoWithAid:(NSNumber *)aid
                       vid:(NSNumber *)vid
                    successBlock:(void(^)(void))successBlock
                    failureBlock:(void(^)(NSString *msg))failureBlock;

/**
 上传视频封面
 
 @param image 视频封面图片
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)uploadVideoCoverImageWithImage:(UIImage *)image
                          successBlock:(void(^)(NSString *url))successBlock
                          failureBlock:(void(^)(NSString *msg))failureBlock;

/**
 上传视频
 
 @param localPath 本地视频地址
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)uploadVideoWithLocalPath:(NSString *)localPath
                    successBlock:(void(^)(NSString *url))successBlock
                    failureBlock:(void(^)(NSString *msg))failureBlock;

@end

NS_ASSUME_NONNULL_END
