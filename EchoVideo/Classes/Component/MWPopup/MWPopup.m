//
//  MWPopup.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/8.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPopup.h"
#import "UIColor+MWUtil.h"

static CGFloat kMWPopupArrowWidth = 12.f;   // 箭头宽度
static CGFloat kMWPopupArrowHeight = 5.f;  // 箭头高度

static CGFloat kMWPopupItemWidth = 150.f;   // 选项item宽度
static CGFloat kMWPopupItemHeight = 50.f;   // 选项item高度

#define MWPOPUP_BACKGROUNDCOLOR [UIColor mw_colorWithHexString:@"393939"]

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

@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MWPopupItem *item;
@property (nonatomic, assign) BOOL hasTopLine;

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
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundButton];
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSubviewsFrame];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.hasTopLine) {
        // 画顶部细线
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGFloat pixelAdjustOffset = 0;
        
        // 落在奇数位置的显示单元上
        if (((int)(1* [UIScreen mainScreen].scale) + 1) % 2 == 0) {
            pixelAdjustOffset = 1/[UIScreen mainScreen].scale/2;
        }
        // 设置画线y值
        CGFloat yPos = 1 - pixelAdjustOffset;
        
        CGFloat minX = 20.f;
        if (self.item.icon) {
            minX =(CGRectGetMaxX(self.iconImageView.frame)+10.f);
        }
        CGContextMoveToPoint(context, minX, yPos);
        CGContextAddLineToPoint(context, CGRectGetWidth(self.titleLabel.frame)+minX, yPos);
        
        CGContextSetLineWidth(context, .5);
        CGContextSetStrokeColorWithColor(context, [UIColor mw_colorWithHexString:@"414141"].CGColor);
        CGContextStrokePath(context);
    }
}

- (void)updateUIWithItem:(MWPopupItem *)item hasTopLine:(BOOL)hasTopLine {
    self.hasTopLine = hasTopLine;
    self.item = item;
    self.iconImageView.image = item.icon;
    self.titleLabel.text = item.title;
    [self updateSubviewsFrame];
    [self setNeedsDisplay];
}

- (void)updateSubviewsFrame {
    self.backgroundButton.frame = self.bounds;
    CGFloat minX = 20.f;
    if (self.item.icon) {
        CGFloat iconWidth = 30.f;
        self.iconImageView.frame = CGRectMake(minX, (kMWPopupItemHeight-iconWidth)/2.f, iconWidth, iconWidth);
        minX+=(iconWidth+10.f);
    }
    CGFloat titleHeight = 20.f;
    self.titleLabel.frame = CGRectMake(minX, (kMWPopupItemHeight-titleHeight)/2.f, CGRectGetWidth(self.bounds)-minX-20.f, titleHeight);
}

- (void)clickBackgroundButton {
    if ([self.delegate respondsToSelector:@selector(itemView:didSelectItem:)]) {
        [self.delegate itemView:self didSelectItem:self.item];
    }
    if (self.item.completion) {
        self.item.completion();
    }
}

#pragma mark -
#pragma mark LazyLoad
- (UIButton *)backgroundButton {
    if (!_backgroundButton) {
        self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundButton addTarget:self action:@selector(clickBackgroundButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundButton;
}

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
        _titleLabel.font = [UIFont systemFontOfSize:17.f];
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

@interface MWPopup () <MWPopupItemViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) NSMutableArray<MWPopupItemView *> *itemViews;

@end

@implementation MWPopup

- (void)showWithItems:(NSArray<MWPopupItem *> *)items {
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.coverView];
    
    MWPopupArrowDirection arrowDirection = MWPopupArrowDirectionTop;
    
    CGRect popupViewFrame;
    CGRect itemsViewFrame;
    switch (arrowDirection) {
        case MWPopupArrowDirectionTop: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame), CGRectGetMinY(popupViewFrame)+kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame), CGRectGetMinY(popupViewFrame), CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth+kMWPopupArrowHeight, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame)+kMWPopupArrowHeight, CGRectGetMinY(popupViewFrame)+kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionRight: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame), CGRectGetMinY(popupViewFrame)+kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        default:
            break;
    }
    
    MWPopupView *popupView = [[MWPopupView alloc] initWithFrame:popupViewFrame];
    popupView.arrowDirection = arrowDirection;
    [self.backgroundView addSubview:popupView];
    
    NSInteger itemIndex = 0;
    for (MWPopupItem *item in items) {
        // 重用itemView
        MWPopupItemView *itemView;
        if (itemIndex < self.itemViews.count) {
            itemView = [self.itemViews objectAtIndex:itemIndex];
        }
        CGRect frame = CGRectMake(CGRectGetMinX(itemsViewFrame),CGRectGetMinY(itemsViewFrame)+itemIndex*kMWPopupItemHeight, CGRectGetWidth(itemsViewFrame), kMWPopupItemHeight);
        if (!itemView) {
            itemView = [[MWPopupItemView alloc] initWithFrame:frame];
            [self.backgroundView addSubview:itemView];
        } else {
            itemView.frame = frame;
            itemView.hidden = NO;
        }
        itemView.delegate = self;
        [itemView updateUIWithItem:item hasTopLine:itemIndex != 0];
        itemIndex++;
    }
    
    for (NSInteger i = itemIndex; i< self.itemViews.count; i++) {
        MWPopupItemView *itemView = [self.itemViews objectAtIndex:i];
        itemView.hidden = YES;
    }
}

- (void)hide {
    [self.backgroundView removeFromSuperview];
}

#pragma mark -
#pragma mark MWPopupItemViewDelegate
- (void)itemView:(MWPopupItemView *)itemView didSelectItem:(MWPopupItem *)item {
    [self hide];
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)backgroundView {
    if (!_backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _backgroundView;
}

- (UIView *)coverView {
    if (!_coverView) {
        self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (NSMutableArray<MWPopupItemView *> *)itemViews {
    if (!_itemViews) {
        self.itemViews = [NSMutableArray array];
    }
    return _itemViews;
}

@end
