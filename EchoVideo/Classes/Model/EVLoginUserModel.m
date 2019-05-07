//
//  EVLoginUserModel.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVLoginUserModel.h"
#import "NSDate+Help.h"

@implementation EVLoginUserModel

- (void)encodeWithCoder:(NSCoder *)aCoder { [self modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self modelCopy]; }
- (NSUInteger)hash { return [self modelHash]; }
- (BOOL)isEqual:(id)object { return [self modelIsEqual:object]; }

+ (EVLoginUserModel *)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self LoadCache];
    });
    return sharedInstance;
}

- (TokenStatus)verifyTokenValid {
    NSDate* expired_date = [NSDate dateFromString:self.expired_date];
    if(expired_date.timeIntervalSinceNow > 60*60*24*7){
        return TokenValid;
    }else if (expired_date.timeIntervalSinceNow > 0){
        return TokenNeedRefresh;
    }
    return TokenExpired;
}

+ (NSString *)DataPath {
    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path  = [docPath stringByAppendingPathComponent:@"loginUser.archiver"];
    return path;
}

+ (EVLoginUserModel *)LoadCache {
    NSString *dataPath = [[self class] DataPath];
    EVLoginUserModel *user = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    if (!user) {
        user = [[EVLoginUserModel alloc] init];
    }
    return user;
}

- (void)save {
    NSString *dataPath = [[self class] DataPath];
    BOOL flag = [NSKeyedArchiver archiveRootObject:self toFile:dataPath];
    if (!flag) {
        NSLog(@"归档失败");
    }
}

- (void)clear {
    self.access_token = nil;
    self.expired_date = nil;
    self.refresh_token = nil;
    self.user = nil;
    NSString *dataPath = [[self class] DataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dataPath]) {
        NSError *error = NULL;
        [fileManager removeItemAtPath:dataPath error:&error];
        if (error) {
            NSLog(@"error = %@", error.localizedDescription);
        }
    }
}

@end
