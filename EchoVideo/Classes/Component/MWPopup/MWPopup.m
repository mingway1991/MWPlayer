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
static CGFloat kMWPopupArrowHeight = 8.f;  // 箭头高度

static CGFloat kMWPopupMinSideMargin = 10.f; // 弹窗距离边框最小边距
static CGFloat kMWPopupArrowMinSideMargin = 10.f; // 箭头距离边最小距离

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
        
        CGFloat minX = CGRectGetMinX(self.titleLabel.frame);
        CGContextMoveToPoint(context, minX, yPos);
        CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), yPos);
        
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
        CGFloat iconWidth = 25.f;
        self.iconImageView.frame = CGRectMake(minX, (CGRectGetHeight(self.bounds)-iconWidth)/2.f, iconWidth, iconWidth);
        minX+=(iconWidth+15.f);
    }
    CGFloat titleHeight = 20.f;
    self.titleLabel.frame = CGRectMake(minX, (CGRectGetHeight(self.bounds)-titleHeight)/2.f, CGRectGetWidth(self.bounds)-minX-20.f, titleHeight);
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
            CGContextMoveToPoint(ctx, self.arrowPoint.x, 0);
            CGContextAddLineToPoint(ctx, self.arrowPoint.x-kMWPopupArrowWidth/2.f, kMWPopupArrowHeight);
            CGContextAddLineToPoint(ctx, self.arrowPoint.x+kMWPopupArrowWidth/2.f, kMWPopupArrowHeight);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            CGContextMoveToPoint(ctx, self.arrowPoint.x, height);
            CGContextAddLineToPoint(ctx, self.arrowPoint.x+kMWPopupArrowWidth/2.f, height-kMWPopupArrowHeight);
            CGContextAddLineToPoint(ctx, self.arrowPoint.x-kMWPopupArrowWidth/2.f, height-kMWPopupArrowHeight);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            CGContextMoveToPoint(ctx, 0, self.arrowPoint.y);
            CGContextAddLineToPoint(ctx, kMWPopupArrowHeight, self.arrowPoint.y-kMWPopupArrowWidth/2.f);
            CGContextAddLineToPoint(ctx, kMWPopupArrowHeight, self.arrowPoint.y+kMWPopupArrowWidth/2.f);
            CGContextClosePath(ctx);
            [MWPOPUP_BACKGROUNDCOLOR setFill];
            CGContextFillPath(ctx);
            break;
        }
        case MWPopupArrowDirectionRight: {
            CGContextMoveToPoint(ctx, width, self.arrowPoint.y);
            CGContextAddLineToPoint(ctx, width-kMWPopupArrowHeight, self.arrowPoint.y+kMWPopupArrowWidth/2.f);
            CGContextAddLineToPoint(ctx, width-kMWPopupArrowHeight, self.arrowPoint.y-kMWPopupArrowWidth/2.f);
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

@property (nonatomic, strong) UIView *backgroundView; // 主view
@property (nonatomic, strong) UIButton *coverButton; // 点击消失button
@property (nonatomic, strong) MWPopupView *popupView; // 弹框背景view
@property (nonatomic, strong) NSMutableArray<MWPopupItemView *> *itemViews; // 选项视图数组

@end

@implementation MWPopup

+ (MWPopup *)shared {
    static dispatch_once_t predicate;
    static MWPopup * popup;
    dispatch_once(&predicate, ^{
        popup = [[MWPopup alloc] init];
    });
    return popup;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.itemWidth = 160.f;
        self.itemHeight = 50.f;
        self.direction = MWPopupDirectionVertical;
        [self.backgroundView addSubview:self.coverButton];
        [self.backgroundView addSubview:self.popupView];
    }
    return self;
}

- (void)showWithItems:(NSArray<MWPopupItem *> *)items
           arrowPoint:(CGPoint)arrowPoint {
    if (!items || items.count == 0) {
        return;
    }
    
    self.backgroundView.frame = self.superView.bounds;
    self.coverButton.frame = self.superView.bounds;
    [self.superView addSubview:self.backgroundView];
    
    CGFloat popupViewX; // 弹出框坐标
    CGFloat popupViewY; // 弹出框坐标
    CGFloat popupViewWidth; // 弹出框区域宽度
    CGFloat popupViewHeight; // 弹出框区域高度
    
    MWPopupArrowDirection arrowDirection; // 箭头方向
    // 计算箭头方向和弹窗宽度和高度
    if (self.direction == MWPopupDirectionVertical) {
        popupViewWidth = self.itemWidth;
        popupViewHeight = kMWPopupArrowHeight+items.count*self.itemHeight;
        if (arrowPoint.y+popupViewHeight+kMWPopupMinSideMargin>CGRectGetHeight(self.superView.bounds)) {
            arrowDirection = MWPopupArrowDirectionBottom;
        } else {
            arrowDirection = MWPopupArrowDirectionTop;
        }
    } else {
        popupViewWidth = self.itemWidth+kMWPopupArrowHeight;
        popupViewHeight = items.count*self.itemHeight;
        if (arrowPoint.x+popupViewWidth+kMWPopupMinSideMargin>CGRectGetWidth(self.superView.bounds)) {
            arrowDirection = MWPopupArrowDirectionRight;
        } else {
            arrowDirection = MWPopupArrowDirectionLeft;
        }
    }
    
    CGRect popupViewFrame;
    CGRect itemsViewFrame;
    switch (arrowDirection) {
        case MWPopupArrowDirectionTop: {
            popupViewX = arrowPoint.x-popupViewWidth/2.f;
            popupViewY = arrowPoint.y;
            break;
        }
        case MWPopupArrowDirectionBottom: {
            popupViewX = arrowPoint.x-popupViewWidth/2.f;
            popupViewY = arrowPoint.y-popupViewHeight;
            break;
        }
        case MWPopupArrowDirectionLeft: {
            popupViewX = arrowPoint.x;
            popupViewY = arrowPoint.y-popupViewHeight/2.f;
            break;
        }
        case MWPopupArrowDirectionRight: {
            popupViewX = arrowPoint.x-popupViewWidth;
            popupViewY = arrowPoint.y-popupViewHeight/2.f;
            break;
        }
        default:
            break;
    }
    
    // 计算弹窗坐标X
    CGFloat popupMinX = (kMWPopupMinSideMargin);
    CGFloat popupMaxX = (CGRectGetWidth(self.superView.bounds)-kMWPopupMinSideMargin-popupViewWidth);
    if (popupViewX > popupMinX && popupViewX < popupMaxX) {
        popupViewX = popupViewX;
    } else if (popupViewX <= popupMaxX) {
        popupViewX = popupMinX;
    } else {
        popupViewX = popupMaxX;
    }
    
    // 计算弹窗坐标Y
    CGFloat popupMinY = (kMWPopupMinSideMargin);
    CGFloat popupMaxY = (CGRectGetHeight(self.superView.bounds)-kMWPopupMinSideMargin-popupViewHeight);
    if (popupViewY > popupMinY && popupViewY < popupMaxY) {
        popupViewY = popupViewY;
    } else if (popupViewY <= popupMinY) {
        popupViewY = popupMinY;
    } else {
        popupViewY = popupMaxY;
    }
    
    switch (arrowDirection) {
        case MWPopupArrowDirectionTop: {
            popupViewFrame = CGRectMake(popupViewX, popupViewY, popupViewWidth, popupViewHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame), CGRectGetMinY(popupViewFrame)+kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            popupViewFrame = CGRectMake(popupViewX, popupViewY, popupViewWidth, popupViewHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame), CGRectGetMinY(popupViewFrame), CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            popupViewFrame = CGRectMake(popupViewX, popupViewY, popupViewWidth, popupViewHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame)+kMWPopupArrowHeight, CGRectGetMinY(popupViewFrame), CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame));
            break;
        }
        case MWPopupArrowDirectionRight: {
            popupViewFrame = CGRectMake(popupViewX, popupViewY, popupViewWidth, popupViewHeight);
            itemsViewFrame = CGRectMake(CGRectGetMinX(popupViewFrame), CGRectGetMinY(popupViewFrame), CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame));
            break;
        }
        default:
            break;
    }
    
    CGFloat arrowPointX; // 箭头相对于popupView的坐标x
    CGFloat arrowPointY; // 箭头相对于popupView的坐标y
    CGFloat arrowMinX;
    CGFloat arrowMaxX;
    CGFloat arrowMinY;
    CGFloat arrowMaxY;
    
    switch (arrowDirection) {
        case MWPopupArrowDirectionTop: {
            arrowPointX = arrowPoint.x;
            arrowPointY = arrowPoint.y;
            arrowMinX = popupViewX+kMWPopupArrowWidth/2.f+kMWPopupArrowMinSideMargin;
            arrowMaxX = popupViewX+popupViewWidth-kMWPopupArrowWidth/2.f-kMWPopupArrowMinSideMargin;
            arrowMinY = popupViewY;
            arrowMaxY = popupViewY;
            break;
        }
        case MWPopupArrowDirectionBottom: {
            arrowPointX = arrowPoint.x;
            arrowPointY = arrowPoint.y;
            arrowMinX = popupViewX+kMWPopupArrowWidth/2.f+kMWPopupArrowMinSideMargin;
            arrowMaxX = popupViewX+popupViewWidth-kMWPopupArrowWidth/2.f-kMWPopupArrowMinSideMargin;
            arrowMinY = popupViewY+popupViewHeight;
            arrowMaxY = popupViewY+popupViewHeight;
            break;
        }
        case MWPopupArrowDirectionLeft: {
            arrowPointX = arrowPoint.x;
            arrowPointY = arrowPoint.y;
            arrowMinX = popupViewX;
            arrowMaxX = popupViewX;
            arrowMinY = popupViewY+kMWPopupArrowWidth/2.f+kMWPopupArrowMinSideMargin;
            arrowMaxY = popupViewY+popupViewHeight-kMWPopupArrowWidth/2.f-kMWPopupArrowMinSideMargin;
            break;
        }
        case MWPopupArrowDirectionRight: {
            arrowPointX = arrowPoint.x;
            arrowPointY = arrowPoint.y;
            arrowMinX = popupViewX+popupViewWidth;
            arrowMaxX = popupViewX+popupViewWidth;
            arrowMinY = popupMinY+kMWPopupArrowWidth/2.f+kMWPopupArrowMinSideMargin;
            arrowMaxY = popupMaxY+popupViewHeight-kMWPopupArrowWidth/2.f-kMWPopupArrowMinSideMargin;
            break;
        }
        default:
            break;
    }
    
    // 计算箭头坐标X
    if (arrowPointX > arrowMinX && arrowPointX < arrowMaxX) {
        arrowPointX = arrowPointX;
    } else if (arrowPoint.x <= arrowMaxX) {
        arrowPointX = arrowMinX;
    } else {
        arrowPointX = arrowMaxX;
    }
    
    // 计算箭头坐标Y
    if (arrowPointY > arrowMinY && arrowPointY < arrowMaxY) {
        arrowPointY = arrowPointY;
    } else if (arrowPoint.y <= arrowMinY) {
        arrowPointY = arrowMinY;
    } else {
        arrowPointY = arrowMaxY;
    }
    
    // 创建弹窗背景视图
    self.popupView.frame = popupViewFrame;
    self.popupView.arrowDirection = arrowDirection;
    self.popupView.arrowPoint = CGPointMake(arrowPointX-popupViewX, arrowPointY-popupViewY);
    [self.popupView setNeedsDisplay];
    
    // 创建弹窗选项视图
    NSInteger itemIndex = 0;
    for (MWPopupItem *item in items) {
        // 重用itemView
        MWPopupItemView *itemView;
        if (itemIndex < self.itemViews.count) {
            itemView = [self.itemViews objectAtIndex:itemIndex];
        }
        CGRect frame = CGRectMake(CGRectGetMinX(itemsViewFrame),CGRectGetMinY(itemsViewFrame)+itemIndex*self.itemHeight, CGRectGetWidth(itemsViewFrame), self.itemHeight);
        if (!itemView) {
            // 创建数量不够的itemView
            itemView = [[MWPopupItemView alloc] initWithFrame:frame];
            [self.backgroundView addSubview:itemView];
            [self.itemViews addObject:itemView];
        } else {
            // 存在的itemView设置新的frame
            itemView.frame = frame;
            itemView.hidden = NO;
        }
        itemView.delegate = self;
        [itemView updateUIWithItem:item hasTopLine:itemIndex != 0];
        itemIndex++;
    }
    
    // 隐藏不需要的itemView
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
        self.backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}

- (UIButton *)coverButton {
    if (!_coverButton) {
        self.coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_coverButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverButton;
}

- (MWPopupView *)popupView {
    if (!_popupView) {
        self.popupView = [[MWPopupView alloc] init];
    }
    return _popupView;
}

- (NSMutableArray<MWPopupItemView *> *)itemViews {
    if (!_itemViews) {
        self.itemViews = [NSMutableArray array];
    }
    return _itemViews;
}

- (UIView *)superView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

@end
