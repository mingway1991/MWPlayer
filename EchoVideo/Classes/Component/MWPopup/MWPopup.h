//
//  MWPopup.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/8.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 弹出框单条选项模型
@interface MWPopupItem : NSObject

@property (nonatomic, strong) UIImage *icon;    // 图标
@property (nonatomic, copy) NSString *title;    // 标题
@property (nonatomic, copy) void(^completion)(void);    // 点击实现block

+ (instancetype)itemWithIcon:(UIImage * _Nullable)icon
                       title:(NSString *)title
                  completion:(void(^)(void))completion;

@end

@class MWPopupItemView;

@protocol MWPopupItemViewDelegate <NSObject>

- (void)itemView:(MWPopupItemView *)itemView didSelectItem:(MWPopupItem *)item;

@end

/// 弹出框单条选项视图
@interface MWPopupItemView : UIView

@property (nonatomic, weak) id<MWPopupItemViewDelegate> delegate;

/*
 更新ui
 
 @param item 选项模型
 @param hasTopLine 是否有顶端线条
 */
- (void)updateUIWithItem:(MWPopupItem *)item
              hasTopLine:(BOOL)hasTopLine;

@end

typedef enum : NSUInteger {
    MWPopupArrowDirectionTop = 0,   // 箭头指向上
    MWPopupArrowDirectionBottom,    // 箭头指向下
    MWPopupArrowDirectionLeft,      // 箭头指向左
    MWPopupArrowDirectionRight,     // 箭头指向右
} MWPopupArrowDirection;

/// 弹出框带箭头背景视图
@interface MWPopupView : UIView

@property (nonatomic, assign) MWPopupArrowDirection arrowDirection; // 箭头朝向
@property (nonatomic, assign) CGPoint arrowPoint; // 箭头顶点位置

@end

typedef enum : NSUInteger {
    MWPopupDirectionVertical = 0, // 箭头竖向显示
    MWPopupDirectionHorizontal, // 箭头横向显示
} MWPopupDirection;

/// 弹出框
@interface MWPopup : NSObject

@property (nonatomic, assign) CGFloat itemWidth;   // 选项item宽度，默认 160
@property (nonatomic, assign) CGFloat itemHeight;   // 选项item高度，默认 50
@property (nonatomic, assign) MWPopupDirection direction; // 箭头方向，水平还是纵向

/*
 使用单例获取实例
 */
+ (MWPopup *)shared;

/*
 显示弹窗
 
 @param items 弹窗选项
 @param arrowPoint 箭头位置
 */
- (void)showWithItems:(NSArray<MWPopupItem *> *)items
           arrowPoint:(CGPoint)arrowPoint;

/*
 隐藏视图
 */
- (void)hide;

@end

NS_ASSUME_NONNULL_END
