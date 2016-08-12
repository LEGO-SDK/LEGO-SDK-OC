//
//  UITabBarController+LGOStatusBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "UITabBarController+LGOStatusBar.h"
#import "UIViewController+LGOStatusBar.h"

@implementation UITabBarController (LGOStatusBar)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [UITabBarController class];
            SEL originalSelector = @selector(setNeedsStatusBarAppearanceUpdate);
            SEL swizzledSelector = @selector(lgo_setNeedsStatusBarAppearanceUpdate);
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        });
    }
}

- (void)lgo_setNeedsStatusBarAppearanceUpdate {
    NSDictionary *value = [NSBundle mainBundle].infoDictionary[@"UIViewControllerBasedStatusBarAppearance"] ;
    if ([value isKindOfClass:[NSNumber class]]){
        if (!((NSNumber *)value).boolValue){
            [[UIApplication sharedApplication] setStatusBarStyle:[self.selectedViewController preferredStatusBarStyle] animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:[self.selectedViewController prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
        }
        else {
            [self lgo_setNeedsStatusBarAppearanceUpdate];
        }
    }
    else {
        [self lgo_setNeedsStatusBarAppearanceUpdate];
    }
}

@end
