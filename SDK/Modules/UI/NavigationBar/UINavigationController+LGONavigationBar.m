//
//  UINavigationController+LGONavigationBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+LGONavigationBar.h"
#import "UIViewController+LGONavigationBar.h"

@implementation UINavigationController (LGONavigationBar)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          Class class = [UINavigationController class];
          SEL originalSelector = @selector(setNeedsStatusBarAppearanceUpdate);
          SEL swizzledSelector = @selector(lgo_setNeedsNavigationBarAppearanceUpdate);
          Method originalMethod = class_getInstanceMethod(class, originalSelector);
          Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
          BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod),
                                              method_getTypeEncoding(swizzledMethod));

          if (didAddMethod) {
              class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod),
                                  method_getTypeEncoding(originalMethod));
          } else {
              method_exchangeImplementations(originalMethod, swizzledMethod);
          }
        });
    }
}

- (void)lgo_setNeedsNavigationBarAppearanceUpdate {
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    [self setNavigationBarHidden:self.visibleViewController.lgo_navigationBarHidden animated:NO];
    [self lgo_setNeedsNavigationBarAppearanceUpdate];
}

@end
