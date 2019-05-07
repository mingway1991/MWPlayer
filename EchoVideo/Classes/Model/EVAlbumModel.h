//
//  EVAlbumModel.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVUserModel.h"

@import YYKit;

NS_ASSUME_NONNULL_BEGIN

@interface EVAlbumModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover_url;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, strong) EVUserModel *creator;
@property (nonatomic, copy) NSString *album_description;
@property (nonatomic, strong) NSNumber *album_id;

@end

NS_ASSUME_NONNULL_END
