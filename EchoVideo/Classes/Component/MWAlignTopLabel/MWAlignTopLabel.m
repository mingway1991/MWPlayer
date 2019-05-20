//
//  MWAlignTopLabel.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/14.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWAlignTopLabel.h"

@implementation MWAlignTopLabel

- (void)setText:(NSString *)text {
    [super setText:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
}

- (void)drawRect:(CGRect)rect {
    [self.attributedText drawInRect:rect];
}

@end
