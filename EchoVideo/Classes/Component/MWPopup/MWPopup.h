//
//  MWPopup.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/8.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

@interface MWPopupItemView : UIView

@property (nonatomic, weak) id<MWPopupItemViewDelegate> delegate;

- (void)updateUIWithItem:(MWPopupItem *)item hasTopLine:(BOOL)hasTopLine;

@end

typedef enum : NSUInteger {
    MWPopupArrowDirectionTop = 0,
    MWPopupArrowDirectionBottom,
    MWPopupArrowDirectionLeft,
    MWPopupArrowDirectionRight,
} MWPopupArrowDirection;

@interface MWPopupView : UIView

@property (nonatomic, assign) MWPopupArrowDirection arrowDirection; // 箭头朝向
@property (nonatomic, assign) CGPoint arrowPoint; // 箭头顶点位置

@end

typedef enum : NSUInteger {
    MWPopupDirectionVertical = 0, // 箭头竖向显示
    MWPopupDirectionHorizontal, // 箭头横向显示
} MWPopupDirection;

@interface MWPopup : NSObject

@property (nonatomic, assign) CGFloat itemWidth;   // 选项item宽度，默认160
@property (nonatomic, assign) CGFloat itemHeight;   // 选项item高度，more50
@property (nonatomic, assign) MWPopupDirection direction; // 箭头方向，水平还是纵向

+ (MWPopup *)shared;

/*
 显示弹窗
 
 @param items 弹窗选项
 @param arrowPoint 箭头位置
 */
- (void)showWithItems:(NSArray<MWPopupItem *> *)items
           arrowPoint:(CGPoint)arrowPoint;

@end

NS_ASSUME_NONNULL_END
