//
//  OssService.h
//  Echo
//
//  Created by zero on 2018/4/8.
//  Copyright © 2018年 zero. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import AliyunOSSiOS;

@interface OssService : NSObject

@property (nonatomic,strong) OSSClient* client;

+ (id)shareInstance;
- (void)asyncPutVideo:(NSData *)videoData objectKey:(NSString*)objectKey Success:(void(^)(BOOL uploadResult))uploadResult;
- (void)asyncPutVideoCoverImage:(NSData *)imageData objectKey:(NSString*)objectKey Success:(void(^)(BOOL uploadResult))uploadResult;

@end
