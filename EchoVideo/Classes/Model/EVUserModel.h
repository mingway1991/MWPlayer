//
//  EVUserModel.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

@import YYKit;

NS_ASSUME_NONNULL_BEGIN

@interface EVUserModel : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cover_url;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSNumber *active;

@end

NS_ASSUME_NONNULL_END
