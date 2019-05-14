//
//  OssService.m
//  Echo
//
//  Created by zero on 2018/4/8.
//  Copyright © 2018年 zero. All rights reserved.
//

#import <AliyunOSSiOS/OSSService.h>
#import "EVWebApi.h"
#import "OssService.h"

NSString * const BUCKET_NAME = @"echo-video";
NSString * const ENDPOINT = @"http://oss-cn-shanghai.aliyuncs.com";
NSString * const UPLOAD_FOLDER = @"upload/";
NSString * const VIDEO_COVER_FOLDER = @"video_cover/";

@import SDWebImage;

@interface OssService ()

@end

@implementation OssService
{
    OSSPutObjectRequest * putRequest;
    OSSGetObjectRequest * getRequest;
    
}

+ (id)shareInstance{
    static OssService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[OssService alloc]init];
        [service ossInit];
    });
    return service;
}

- (id)initWithViewController:(UIViewController *)view
                withEndPoint:(NSString *)enpoint {
    if (self = [super init]) {
        [self ossInit];
    }
    return self;
}

/**
 *    @brief    初始化获取OSSClient
 */
- (void)ossInit {
    //     移动终端是一个不受信任的环境，使用主账号AK，SK直接保存在终端用来加签请求，存在极高的风险。建议只在测试时使用明文设置模式，业务应用推荐使用STS鉴权模式。
    //     STS鉴权模式可通过https://help.aliyun.com/document_detail/31920.html文档了解更多
    //     主账号方式
    //     id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithAccessKeyId:@"Aliyun_AK" secretKeyId:@"Aliyun_SK"];
    //     如果用STS鉴权模式，推荐使用OSSAuthCredentialProvider方式直接访问鉴权应用服务器，token过期后可以自动更新。
    //     详见：https://help.aliyun.com/document_detail/31920.html
    //     OSSClient的生命周期和应用程序的生命周期保持一致即可。在应用程序启动时创建一个ossClient，在应用程序结束时销毁即可。
    id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
        // 构造请求访问您的业务server
        NSURL * url = [NSURL URLWithString:kEchoVideoOssApi];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
        NSURLSession * session = [NSURLSession sharedSession];
        // 发送请求
        NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            [tcs setError:error];
                                                            return;
                                                        }
                                                        [tcs setResult:data];
                                                    }];
        [sessionTask resume];
        // 需要阻塞等待请求返回
        [tcs.task waitUntilFinished];
        // 解析结果
        if (tcs.task.error) {
            NSLog(@"get token error: %@", tcs.task.error);
            return nil;
        } else {
            // 返回数据是json格式，需要解析得到token的各个字段
            NSDictionary * object = [NSJSONSerialization JSONObjectWithData:tcs.task.result
                                                                    options:kNilOptions
                                                                      error:nil];
            OSSFederationToken * token = [OSSFederationToken new];
            token.tAccessKey = [object objectForKey:@"AccessKeyId"];
            token.tSecretKey = [object objectForKey:@"AccessKeySecret"];
            token.tToken = [object objectForKey:@"SecurityToken"];
            token.expirationTimeInGMTFormat = [object objectForKey:@"Expiration"];
            NSLog(@"get token: %@", token);
            return token;
        }
    }];
    _client = [[OSSClient alloc] initWithEndpoint:ENDPOINT credentialProvider:credential];
}

- (void)asyncPutVideoCoverImage:(NSData *)imageData objectKey:(NSString*)objectKey Success:(void(^)(BOOL uploadResult))uploadResult {
    if (objectKey == nil || [objectKey length] == 0) {
        return;
    }
    [self _asyncPutData:imageData objectKey:[NSString stringWithFormat:@"%@%@",VIDEO_COVER_FOLDER,objectKey] Success:uploadResult];
}

- (void)asyncPutVideo:(NSData *)videoData objectKey:(NSString*)objectKey Success:(void(^)(BOOL uploadResult))uploadResult {
    if (objectKey == nil || [objectKey length] == 0) {
        return;
    }
    [self _asyncPutData:videoData objectKey:[NSString stringWithFormat:@"%@%@",UPLOAD_FOLDER,objectKey] Success:uploadResult];
}

- (void)_asyncPutData:(NSData *)data objectKey:(NSString*)objectKey Success:(void(^)(BOOL uploadResult))uploadResult {
    putRequest = [OSSPutObjectRequest new];
    putRequest.bucketName = BUCKET_NAME;
    putRequest.objectKey = objectKey;
    putRequest.uploadingData = data;
    putRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    OSSTask * task = [_client putObject:putRequest];
    [task continueWithBlock:^id(OSSTask *task) {
        NSLog(@"videoName:%@",objectKey);
        OSSPutObjectResult * result = task.result;
        // 查看server callback是否成功
        if (!task.error) {
            NSLog(@"Put video success!");
            NSLog(@"server callback : %@", result.serverReturnJsonString);
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadResult(YES);
            });
            
        } else {
            NSLog(@"Put video failed, %@", task.error);
            if (task.error.code == OSSClientErrorCodeTaskCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadResult(NO);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadResult(NO);
                });
            }
        }
        self->putRequest = nil;
        return nil;
    }];
}

/**
 *    @brief    普通上传/下载取消
 */
- (void)normalRequestCancel {
    if (putRequest) {
        [putRequest cancel];
    }
    if (getRequest) {
        [getRequest cancel];
    }
}

@end
