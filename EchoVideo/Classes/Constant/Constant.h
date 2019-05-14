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

#endif /* Constant_h */
