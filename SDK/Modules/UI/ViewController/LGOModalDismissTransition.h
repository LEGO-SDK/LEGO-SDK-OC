//
//  LGOModalDismissTransition.h
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGOModalDismissTransition : NSObject<UIViewControllerAnimatedTransitioning>
- (instancetype)initWithTargetEdgeInsets:(UIEdgeInsets)insets;
@property (nonatomic, assign) UIEdgeInsets targetEdgeInsets;
@end
