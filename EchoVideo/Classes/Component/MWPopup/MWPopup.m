//
//  MWPopup.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/8.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPopup.h"

static CGFloat kMWPopupArrowWidth = 12.f;   // 箭头宽度
static CGFloat kMWPopupArrowHeight = 5.f;  // 箭头高度

static CGFloat kMWPopupItemWidth = 100.f;   // 选项item宽度
static CGFloat kMWPopupItemHeight = 44.f;   // 选项item高度

#define MWPOPUP_BACKGROUNDCOLOR [UIColor grayColor]

@implementation MWPopupItem

+ (instancetype)itemWithIcon:(UIImage * _Nullable)icon
                       title:(NSString *)title
                  completion:(void(^)(void))completion {
    MWPopupItem *item = [[MWPopupItem alloc] init];
    item.icon = icon;
    item.title = title;
    item.completion = completion;
    return item;
}

@end

@interface MWPopupItemView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MWPopupItem *item;

@end

@implementation MWPopupItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSubviewsFrame];
}

- (void)updateUIWithItem:(MWPopupItem *)item {
    self.item = item;
    self.iconImageView.image = item.icon;
    self.titleLabel.text = item.title;
    [self updateSubviewsFrame];
}

- (void)updateSubviewsFrame {
    CGFloat minX = 10.f;
    if (self.item.icon) {
        CGFloat iconWidth = 30.f;
        self.iconImageView.frame = CGRectMake(minX, (kMWPopupItemHeight-iconWidth)/2.f, iconWidth, iconWidth);
        minX+=(iconWidth+10.f);
    }
    CGFloat titleHeight = 20.f;
    self.titleLabel.frame = CGRectMake(minX, (kMWPopupItemHeight-titleHeight)/2.f, CGRectGetWidth(self.bounds)-minX-10.f, titleHeight);
}

#pragma mark -
#pragma mark LazyLoad
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        self.iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end

@implementation MWPopupView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    
    // 画箭头
    [self drawArrowWithContext:ctx];
    // 画圆角矩形
    [self drawRoundedRectangleWithContext:ctx];
    
    CGContextSaveGState(ctx);
    CGContextRestoreGState(ctx);
}

- (void)drawArrowWithContext:(CGContextRef)ctx {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    switch (self.arrowDirection) {
        case MWPopupArrowDirectionTop: {
            CGContextMoveToPoint(ctx, width/2.f, 0);
            CGContextAddLineToPoint(ctx, width/2.f-kMWPopupArrowWidth/2.f, kMWPopupArrowHeight);
            CGContextAddLineToPoint(ctx, width/2.f+kMWPopupArrowWidth/2.f, kMWPopupArrowHeight);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            CGContextMoveToPoint(ctx, width/2.f, height);
            CGContextAddLineToPoint(ctx, width/2.f+kMWPopupArrowWidth/2.f, height-kMWPopupArrowHeight);
            CGContextAddLineToPoint(ctx, width/2.f-kMWPopupArrowWidth/2.f, height-kMWPopupArrowHeight);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            CGContextMoveToPoint(ctx, 0, height/2.f);
            CGContextAddLineToPoint(ctx, kMWPopupArrowHeight, height/2.f-kMWPopupArrowWidth/2.f);
            CGContextAddLineToPoint(ctx, kMWPopupArrowHeight, height/2.f+kMWPopupArrowWidth/2.f);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        case MWPopupArrowDirectionRight: {
            CGContextMoveToPoint(ctx, width, height/2.f);
            CGContextAddLineToPoint(ctx, width-kMWPopupArrowHeight, height/2.f+kMWPopupArrowWidth/2.f);
            CGContextAddLineToPoint(ctx, width-kMWPopupArrowHeight, height/2.f-kMWPopupArrowWidth/2.f);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        default:
            break;
    }
}

- (void)drawRoundedRectangleWithContext:(CGContextRef)ctx {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGRect rect = CGRectZero;
    
    switch (self.arrowDirection) {
        case MWPopupArrowDirectionTop: {
            rect = CGRectMake(0, kMWPopupArrowHeight, width, height-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            rect = CGRectMake(0, 0, width, height-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            rect = CGRectMake(kMWPopupArrowHeight, 0, width-kMWPopupArrowHeight, height);
            break;
        }
        case MWPopupArrowDirectionRight: {
            rect = CGRectMake(0, 0, width-kMWPopupArrowHeight, height);
            break;
        }
        default:
            break;
    }
    
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGFloat filletRadius = 5.f;
    CGContextMoveToPoint(ctx, minx, midy);
    CGContextAddArcToPoint(ctx, minx, miny, midx, miny, filletRadius);
    CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, filletRadius);
    CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, filletRadius);
    CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, filletRadius);
    CGContextClosePath(ctx);
    [MWPOPUP_BACKGROUNDCOLOR setFill];
    CGContextFillPath(ctx);
}

@end

@interface MWPopup ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) NSArray<MWPopupItem *> *items;

@end

@implementation MWPopup

- (void)showWithItems:(NSArray<MWPopupItem *> *)items {
    [[UIApplication sharedApplication].keyWindow addSubview:self.coverView];
    
    self.items = items;
    
    MWPopupArrowDirection arrowDirection = MWPopupArrowDirectionTop;
    
    CGRect popupViewFrame;
    CGRect itemsViewFrame;
    switch (arrowDirection) {
        case MWPopupArrowDirectionTop: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(0, kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(0, 0, CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth+kMWPopupArrowHeight, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(kMWPopupArrowHeight, kMWPopupArrowHeight+kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionRight: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(0, kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        default:
            break;
    }
    
    MWPopupView *popupView = [[MWPopupView alloc] initWithFrame:popupViewFrame];
    popupView.arrowDirection = arrowDirection;
    
    NSInteger itemIndex = 0;
    for (MWPopupItem *item in items) {
        MWPopupItemView *itemView = [[MWPopupItemView alloc] initWithFrame:CGRectMake(CGRectGetMinX(itemsViewFrame),CGRectGetMinY(itemsViewFrame)+itemIndex*kMWPopupItemHeight, CGRectGetWidth(itemsViewFrame), kMWPopupItemHeight)];
        [itemView updateUIWithItem:item];
        [popupView addSubview:itemView];
        itemIndex++;
    }
    
    [self.coverView addSubview:popupView];
}

- (void)hide {
    [self.coverView removeFromSuperview];
    self.coverView = nil;
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)coverView {
    if (!_coverView) {
        self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

@end
