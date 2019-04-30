//
//  MWPlayerProgressView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWPlayerProgressView;

NS_ASSUME_NONNULL_BEGIN

@protocol MWPlayerProgressViewDelegate <NSObject>

- (void)progressViewBeginPanProgress:(MWPlayerProgressView *)progressView;
- (void)progressViewHandlePanProgress:(MWPlayerProgressView *)progressView percent:(float)percent;
- (void)progressViewEndPanProgress:(MWPlayerProgressView *)progressView;

@end

@interface MWPlayerProgressView : UIView

@property (nonatomic, weak) id<MWPlayerProgressViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval totalTimeInterval;
@property (nonatomic, assign) NSTimeInterval cacheTimeInterval;
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;

@end

NS_ASSUME_NONNULL_END
