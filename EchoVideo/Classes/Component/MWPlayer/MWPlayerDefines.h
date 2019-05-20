//
//  MWPlayerDefines.h
//  Pods
//
//  Created by 石茗伟 on 2018/9/4.
//

#ifndef MWPlayerDefines_h
#define MWPlayerDefines_h

#define force_inline __inline__ __attribute__((always_inline))

// NSLog
#ifdef DEBUG
#define NSLog(fmt, ...)  NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(...)
#endif

// 全局配置
#define MWPlayerScreenWidth [UIScreen mainScreen].bounds.size.width
#define MWPlayerScreenHeight [UIScreen mainScreen].bounds.size.height

// get
#define MWPlayerGetMinX(view) CGRectGetMinX(view.frame)//视图最小X坐标
#define MWPlayerGetMinY(view) CGRectGetMinY(view.frame)//视图最小Y坐标
#define MWPlayerGetMidX(view) CGRectGetMidX(view.frame)//视图中间X坐标
#define MWPlayerGetMidY(view) CGRectGetMidY(view.frame)//视图中间Y坐标
#define MWPlayerGetMaxX(view) CGRectGetMaxX(view.frame)//视图最大X坐标
#define MWPlayerGetMaxY(view) CGRectGetMaxY(view.frame)//视图最大Y坐标
#define MWPlayerGetWidth(view) CGRectGetWidth(view.frame)//视图宽度
#define MWPlayerGetHeight(view) CGRectGetHeight(view.frame)//视图高度
#define MWPlayerGetCenterX(view) view.center.x//centerX
#define MWPlayerGetCenterY(view) view.center.y//centerY

//set
#define MWPlayerSetMinX(view,x) view.frame = CGRectMake(x,MWPlayerGetMinY(view),MWPlayerGetWidth(view),MWPlayerGetHeight(view))
#define MWPlayerSetMinY(view,y) view.frame = CGRectMake(MWPlayerGetMinX(view),y,MWPlayerGetWidth(view),MWPlayerGetHeight(view))
#define MWPlayerSetWidth(view,width) view.frame = CGRectMake(MWPlayerGetMinX(view),MWPlayerGetMinY(view),width,MWPlayerGetHeight(view))
#define MWPlayerSetHeight(view,height) view.frame = CGRectMake(MWPlayerGetMinX(view),MWPlayerGetMinY(view),MWPlayerGetWidth(view),height)
#define MWPlayerSetCenterX(view,x) view.center = CGPointMake(x,MWPlayerGetCenterY(view))
#define MWPlayerSetCenterY(view,y) view.center = CGPointMake(MWPlayerGetCenterX(view),y)

// 角度转弧度
#define MWPlayerDegreeToRadian(x) (M_PI * x / 180.0)
// 弧度转角度
#define MWPlayerRadianToDegree(x) (180.0 * x / M_PI)

#endif /* MWPlayerDefines_h */
