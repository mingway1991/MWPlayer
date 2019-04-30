//
//  MWPlayerView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MWPlayerView : UIView

@property (nonatomic, copy) NSString *videoUrl;

- (void)play;
- (void)pause;
- (void)pointToPlay:(float)percent;

@end

NS_ASSUME_NONNULL_END
