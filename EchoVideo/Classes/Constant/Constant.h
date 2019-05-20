//
//  Constant.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/7.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define LEFT_RIGHT_MARGIN 10.f

#define VIDEO_URL(video_name) [NSString stringWithFormat:@"https://echo-video.oss-cn-shanghai.aliyuncs.com/upload/%@", video_name]
#define VIDEO_COVER_URL(image_name) [NSString stringWithFormat:@"https://echo-video.oss-cn-shanghai.aliyuncs.com/video_cover/%@", image_name]

#define THEME_COLOR @"00FF7F"
#define BOTTOM_LINE_COLOR @"CFCFCF"

#define SWITCH_LOGIN_NOTIFICATION_NAME @"siwtch_login"
#define SWITCH_HOME_NOTIFICATION_NAME @"switch_home"


// 全局配置
#define MWScreenWidth [UIScreen mainScreen].bounds.size.width
#define MWScreenHeight [UIScreen mainScreen].bounds.size.height

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXS_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
#define kiPhoneXAll ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

// 导航条高度
#define MWNavigationBarHeight 44.f
// 状态栏高度，如果状态栏隐藏则会返回0
#define MWStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
// 状态栏加导航条高度
#define MWTopBarHeight MWStatusBarHeight+MWNavigationBarHeight
// tabbar高度
#define MWTabBarHeight 49.f
// 安全区域高度
#define MWSafeAreaHeight (kiPhoneXAll ? 34.f : 0.f)

#endif /* Constant_h */
