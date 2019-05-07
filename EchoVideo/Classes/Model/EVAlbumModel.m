//
//  EVAlbumModel.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVAlbumModel.h"

@implementation EVAlbumModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"album_id" : @"id", @"album_description": @"description"};
}

@end
