//
//  EVNewVideoView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EVNewVideoView;

NS_ASSUME_NONNULL_BEGIN

@protocol EVNewVideoViewDelegate <NSObject>

- (void)newVideoView:(EVNewVideoView *)newVideoView title:(NSString *)title url:(NSString *)url;

@end

@interface EVNewVideoView : UIView

@property (nonatomic, weak) id<EVNewVideoViewDelegate> delegate;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
