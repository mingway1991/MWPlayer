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

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void(^completiom)(void);

+ (instancetype)itemWithIcon:(UIImage *)icon
                       title:(NSString *)title
                  completion:(void(^)(void))completion;

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
