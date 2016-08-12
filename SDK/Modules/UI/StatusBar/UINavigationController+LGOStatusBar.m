//
//  UINavigationController+LGOStatusBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+LGOStatusBar.h"
#import "UIViewController+LGOStatusBar.h"

@implementation UINavigationController (LGOStatusBar)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [UINavigationController class];
            SEL originalSelector = @selector(preferredStatusBarStyle);
            SEL swizzledSelector = @selector(lgo_preferredStatusBarStyle);
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
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [UINavigationController class];
            SEL originalSelector = @selector(prefersStatusBarHidden);
            SEL swizzledSelector = @selector(lgo_prefersStatusBarHidden);
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
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [UINavigationController class];
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
            [[UIApplication sharedApplication] setStatusBarStyle:[self.visibleViewController preferredStatusBarStyle] animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:[self.visibleViewController prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
        }
        else {
            [self lgo_setNeedsStatusBarAppearanceUpdate];
        }
    }
    else {
        [self lgo_setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle)lgo_preferredStatusBarStyle {
    return [self.visibleViewController preferredStatusBarStyle];
}

- (BOOL)lgo_prefersStatusBarHidden {
    return [self.visibleViewController prefersStatusBarHidden];
}

@end
