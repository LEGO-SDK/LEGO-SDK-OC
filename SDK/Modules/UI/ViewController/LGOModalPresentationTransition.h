//
//  LGOModalPresentationTransition.h
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGOModalPresentationTransition : NSObject<UIViewControllerAnimatedTransitioning>
- (id)initWithTargetEdgeInsets:(UIEdgeInsets)insets;
@property (nonatomic, assign) UIEdgeInsets targetEdgeInsets;
@property (nonatomic, strong) UIView *maskView;
@end
