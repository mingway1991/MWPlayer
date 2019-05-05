//
//  MWPlayerLoadingProtocol.h
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/5.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#ifndef MWPlayerLoadingProtocol_h
#define MWPlayerLoadingProtocol_h

@class UIView;

@protocol MWPlayerLoadingProtocol <NSObject>

- (void)startAnimating;
- (void)stopAnimating;

@end

#endif /* MWPlayerLoadingProtocol_h */
