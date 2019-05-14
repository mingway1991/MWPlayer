//
//  EVNewVideoView.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EVNewVideoView;

typedef enum : NSUInteger {
    EVNewVideoTypeUrl = 0,  // 远端url
    EVNewVideoTypeLocal,    // 本地录制视频
} EVNewVideoType;

NS_ASSUME_NONNULL_BEGIN

@protocol EVNewVideoViewDelegate <NSObject>

- (void)newVideoView:(EVNewVideoView *)newVideoView title:(NSString *)title url:(NSString *)url;
- (void)newVideoView:(EVNewVideoView *)newVideoView title:(NSString *)title localVideoPath:(NSString *)localVideoPath;

@end

@interface EVNewVideoView : UIView

@property (nonatomic, weak) id<EVNewVideoViewDelegate> delegate;
@property (nonatomic, copy) NSString *localVideoPath;
@property (nonatomic, assign) EVNewVideoType type;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithType:(EVNewVideoType)type NS_DESIGNATED_INITIALIZER;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
