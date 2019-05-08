//
//  MWPopup.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/8.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWPopup.h"

static CGFloat kMWPopupArrowWidth = 15.f;   // 箭头宽度
static CGFloat kMWPopupArrowHeight = 10.f;  // 箭头高度

static CGFloat kMWPopupItemWidth = 100.f;   // 选项item宽度
static CGFloat kMWPopupItemHeight = 44.f;   // 选项item高度

#define MWPOPUP_BACKGROUNDCOLOR [UIColor blackColor]

@implementation MWPopupItem

+ (instancetype)itemWithIcon:(UIImage *)icon
                       title:(NSString *)title
                  completion:(void(^)(void))completion {
    MWPopupItem *item = [[MWPopupItem alloc] init];
    item.icon = icon;
    item.title = title;
    item.completiom = completion;
    return item;
}

@end

@interface MWPopupView () {
    CGFloat _arrowWidth;
    CGFloat _arrowHeight;
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
    [[UIColor blackColor] setFill];
    CGContextFillPath(ctx);
}

@end

@interface MWPopup () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) NSArray<MWPopupItem *> *items;

@end

@implementation MWPopup

- (void)showWithItems:(NSArray<MWPopupItem *> *)items {
    self.items = items;
    
    MWPopupArrowDirection arrowDirection = MWPopupArrowDirectionTop;
    
    CGRect popupViewFrame;
    CGRect itemsTableViewFrame;
    switch (arrowDirection) {
        case MWPopupArrowDirectionTop: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsTableViewFrame = CGRectMake(0, kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionBottom: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsTableViewFrame = CGRectMake(0, 0, CGRectGetWidth(popupViewFrame), CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionLeft: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth+kMWPopupArrowHeight, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsTableViewFrame = CGRectMake(kMWPopupArrowHeight, kMWPopupArrowHeight+kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        case MWPopupArrowDirectionRight: {
            popupViewFrame = CGRectMake(30.f, 40.f, kMWPopupItemWidth, kMWPopupArrowHeight+items.count*kMWPopupItemHeight);
            itemsTableViewFrame = CGRectMake(0, kMWPopupArrowHeight, CGRectGetWidth(popupViewFrame)-kMWPopupArrowHeight, CGRectGetHeight(popupViewFrame)-kMWPopupArrowHeight);
            break;
        }
        default:
            break;
    }
    
    MWPopupView *popupView = [[MWPopupView alloc] initWithFrame:popupViewFrame];
    popupView.arrowDirection = arrowDirection;
    popupView.clipsToBounds = YES;
    [self.coverView addSubview:popupView];
    
    UITableView *itemsTableView = [[UITableView alloc] initWithFrame:itemsTableViewFrame];
    itemsTableView.dataSource = self;
    itemsTableView.delegate = self;
    itemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    itemsTableView.backgroundColor = [UIColor clearColor];
    itemsTableView.scrollEnabled = NO;
    [popupView addSubview:itemsTableView];
    [itemsTableView reloadData];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.coverView];
}

- (void)hide {
    [self.coverView removeFromSuperview];
    self.coverView = nil;
}

#pragma mark -
#pragma mark UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMWPopupItemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"mwPopupItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [self.items[indexPath.row] title];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -
#pragma mark LazyLoad
- (UIView *)coverView {
    if (!_coverView) {
        self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

@end
