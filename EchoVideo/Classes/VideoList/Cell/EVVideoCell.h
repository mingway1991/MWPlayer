//
//  EVVideoCell.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/14.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVVideoCell : UITableViewCell

- (void)updateUIWithVideo:(EVVideoModel *)video
                     date:(NSString *)date
                    index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
