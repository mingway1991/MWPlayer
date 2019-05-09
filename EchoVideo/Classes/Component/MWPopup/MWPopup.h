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
@property (nonatomic, copy) void(^completion)(void);    //

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

@property (nonatomic, assign) MWPopupArrowDirection arrowDirection;

@end

@interface MWPopup : NSObject

- (void)showWithItems:(NSArray<MWPopupItem *> *)items;

@end

NS_ASSUME_NONNULL_END
