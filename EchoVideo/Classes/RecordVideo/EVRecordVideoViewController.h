//
//  EVRecordVideoViewController.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/9.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVBaseViewController.h"

@class EVRecordVideoViewController;

@protocol EVRecordVideoViewControllerDelegate <NSObject>

- (void)recordVideoViewController:(EVRecordVideoViewController *)recordVideoViewController finishRecordWithLocalPath:(NSString *)localPath;

@end

NS_ASSUME_NONNULL_BEGIN

@interface EVRecordVideoViewController : EVBaseViewController

@property (nonatomic, weak) id<EVRecordVideoViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
