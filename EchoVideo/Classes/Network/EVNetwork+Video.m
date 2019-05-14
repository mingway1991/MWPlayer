//
//  EVNetwork+Video.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVNetwork+Video.h"
#import "EVWebApi.h"
#import "OssService.h"
#import "EVLoginUserModel.h"

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

- (void)deleteVideoWithAid:(NSNumber *)aid
                       vid:(NSNumber *)vid
              successBlock:(void(^)(void))successBlock
              failureBlock:(void(^)(NSString *msg))failureBlock {
    [self requestDeleteUrl:kDeleteVideoOfAlbumApi(aid, vid) Parameters:nil Success:^(id result) {
        successBlock();
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

- (void)uploadVideoWithLocalPath:(NSString *)localPath
                    successBlock:(void(^)(NSString *url))successBlock
                    failureBlock:(void(^)(NSString *msg))failureBlock {
    NSData *videoData = [NSData dataWithContentsOfFile:localPath];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSInteger time = interval;
    NSString *timestamp = [NSString stringWithFormat:@"%zd",time];
    NSString *objectKey = [NSString stringWithFormat:@"%@_%@.mov", [EVLoginUserModel sharedInstance].user.uid, timestamp];
    [[OssService shareInstance] asyncPutVideo:videoData objectKey:objectKey Success:^(BOOL uploadResult) {
        if (uploadResult) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:localPath error:&error];
            if (error) {
                NSLog(@"删除本地视频failed：%@", error.localizedDescription);
            } else {
                NSLog(@"删除本地视频成功");
            }
            successBlock([NSString stringWithFormat:@"https://echo-video.oss-cn-shanghai.aliyuncs.com/upload/%@", objectKey]);
        } else {
            failureBlock(@"上传视频失败");
        }
    }];
}

@end
