//
//  LGOModalDismissTransition.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOModalDismissTransition.h"

@implementation LGOModalDismissTransition

- (instancetype)initWithTargetEdgeInsets:(UIEdgeInsets)insets
{
    self = [super init];
    if (self) {
        _targetEdgeInsets = insets;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.30;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (fromVC == nil) {
        return ;
    }
    UIView *containerView = [transitionContext containerView];
    if (containerView != nil){
        UIView *maskView = [containerView viewWithTag:999];
        fromVC.view.frame = [self endRect];
        [UIView animateWithDuration:0.30 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:15.0 options:kNilOptions animations:^{
            fromVC.view.frame = [self startRect];
            if (maskView != nil){
                maskView.alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            fromVC.view.frame = [self startRect];
            if (maskView != nil){
                maskView.alpha = 0.0;
            }
            [transitionContext completeTransition:YES];
        }];
    }
}


- (CGRect)startRect{
    if (self.targetEdgeInsets.bottom < 0.0 && self.targetEdgeInsets.top == 0.0){
        CGRect frame = [self endRect];
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        return frame;
    }
    return [self endRect];
}

- (CGRect)endRect{
    CGRect frame = [UIScreen mainScreen].bounds;
    if(self.targetEdgeInsets.bottom < 0.0 && self.targetEdgeInsets.top == 0.0){
        frame.origin.y = [UIScreen mainScreen].bounds.size.height + self.targetEdgeInsets.bottom;
        frame.size.height = - self.targetEdgeInsets.bottom;
        return frame;
    }
    if (self.targetEdgeInsets.top > 0.0){
        frame.origin.y = self.targetEdgeInsets.top;
    }
    if (self.targetEdgeInsets.left > 0.0) {
        frame.origin.x = self.targetEdgeInsets.top;
    }
    if (self.targetEdgeInsets.bottom > 0.0){
        frame.size.height = [UIScreen mainScreen].bounds.size.height - frame.origin.y - self.targetEdgeInsets.bottom;
    }
    if (self.targetEdgeInsets.right > 0.0){
        frame.size.width = [UIScreen mainScreen].bounds.size.width - frame.origin.x - self.targetEdgeInsets.right;
    }
    return frame;
}

@end
