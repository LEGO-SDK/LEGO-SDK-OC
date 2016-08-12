//
//  UIViewController+LGOStatusBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+LGOStatusBar.h"

@implementation UIViewController (LGOStatusBar)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [UIViewController class];
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
            Class class = [UIViewController class];
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
}

- (void)lgo_setNeedsStatusBarAppearanceUpdate:(BOOL)animated {
    NSDictionary *value = [NSBundle mainBundle].infoDictionary[@"UIViewControllerBasedStatusBarAppearance"] ;
    if ([value isKindOfClass:[NSNumber class]]){
        if (!((NSNumber *)value).boolValue){
            [[UIApplication sharedApplication] setStatusBarStyle:self.lgo_statusBarStyle animated:animated];
            [[UIApplication sharedApplication] setStatusBarHidden:self.lgo_statusBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
        }
    }
}

- (UIStatusBarStyle)lgo_preferredStatusBarStyle {
    return self.lgo_statusBarStyle;
}

- (BOOL)lgo_prefersStatusBarHidden {
    return self.lgo_statusBarHidden;
}

static int kStatusBarStyleIdentifierKey;

- (UIStatusBarStyle)lgo_statusBarStyle {
    return objc_getAssociatedObject(self, &kStatusBarStyleIdentifierKey) == nil ? UIStatusBarStyleDefault : [objc_getAssociatedObject(self, &kStatusBarStyleIdentifierKey) integerValue];
}

- (void)setLgo_statusBarStyle:(UIStatusBarStyle)lgo_statusBarStyle {
    objc_setAssociatedObject(self, &kStatusBarStyleIdentifierKey, @(lgo_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static int kStatusBarHiddenIdentifierKey;

- (BOOL)lgo_statusBarHidden {
    return objc_getAssociatedObject(self, &kStatusBarHiddenIdentifierKey) == nil ? NO : [objc_getAssociatedObject(self, &kStatusBarHiddenIdentifierKey) boolValue];
}

- (void)setLgo_statusBarHidden:(BOOL)lgo_statusBarHidden {
    objc_setAssociatedObject(self, &kStatusBarHiddenIdentifierKey, @(lgo_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
