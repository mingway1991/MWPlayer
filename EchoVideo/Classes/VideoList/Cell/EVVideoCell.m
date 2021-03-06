//
//  EVVideoCell.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/14.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVVideoCell.h"
#import "MWAlignTopLabel.h"
#import "Constant.h"

@import SDWebImage;

@interface EVVideoCell ()

@property (nonatomic, strong) MWAlignTopLabel *dateLabel;
@property (nonatomic, strong) UIImageView *videoCoverImageView;
@property (nonatomic, strong) MWAlignTopLabel *titleLabel;

@end

@implementation EVVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.videoCoverImageView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateLabel.frame = CGRectMake(10.f, 10.f, 80.f, 50.f);
    self.videoCoverImageView.frame = CGRectMake(CGRectGetMaxX(self.dateLabel.frame)+10.f, CGRectGetMinY(self.dateLabel.frame), 60.f, 60.f);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.videoCoverImageView.frame)+10.f, CGRectGetMinY(self.videoCoverImageView.frame), CGRectGetWidth(self.contentView.bounds)-CGRectGetMaxX(self.videoCoverImageView.frame)-10.f-10.f, 60.f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.videoCoverImageView.image = nil;
}

- (void)updateUIWithVideo:(EVVideoModel *)video
                     date:(NSString *)date
                    index:(NSInteger)index {
    self.dateLabel.hidden = (index != 0);
    
    NSArray *separatedDate = [date componentsSeparatedByString:@"-"];
    long year = [separatedDate[0] longValue];
    long month = [separatedDate[1] longValue];
    long day = [separatedDate[2] longValue];
    NSString *dayStr = [NSString stringWithFormat:@"%02ld",day];
    NSString *monthStr = [NSString stringWithFormat:@" %@月",@(month)];
    NSString *yearStr = [NSString stringWithFormat:@"\n%@年",@(year)];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", dayStr, monthStr, yearStr]];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28.f] range:NSMakeRange(0, dayStr.length)];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(dayStr.length, monthStr.length)];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.f] range:NSMakeRange(dayStr.length+monthStr.length, yearStr.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, dayStr.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(dayStr.length, monthStr.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(dayStr.length+monthStr.length, yearStr.length)];
    self.dateLabel.attributedText = attr;
    
    self.titleLabel.text = video.title;
    
    if (video.cover_url.length > 0) {
        [self.videoCoverImageView sd_setImageWithURL:[NSURL URLWithString:VIDEO_COVER_URL(video.cover_url)]];
    } else {
        
    }
}

#pragma mark -
#pragma mark LazyLoad
- (MWAlignTopLabel *)dateLabel {
    if (!_dateLabel) {
        self.dateLabel = [[MWAlignTopLabel alloc] init];
        _dateLabel.numberOfLines = 2;
    }
    return _dateLabel;
}

- (UIImageView *)videoCoverImageView {
    if (!_videoCoverImageView) {
        self.videoCoverImageView = [[UIImageView alloc] init];
        _videoCoverImageView.backgroundColor = [UIColor yellowColor];
    }
    return _videoCoverImageView;
}

- (MWAlignTopLabel *)titleLabel {
    if (!_titleLabel) {
        self.titleLabel = [[MWAlignTopLabel alloc] init];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

@end
