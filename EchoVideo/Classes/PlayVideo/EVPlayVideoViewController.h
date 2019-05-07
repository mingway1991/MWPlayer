//
//  EVPlayVideoViewController.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVBaseViewController.h"
#import "EVVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVPlayVideoViewController : EVBaseViewController

@property (nonatomic, strong) NSArray<EVVideoModel *> *videos;

@end

NS_ASSUME_NONNULL_END
