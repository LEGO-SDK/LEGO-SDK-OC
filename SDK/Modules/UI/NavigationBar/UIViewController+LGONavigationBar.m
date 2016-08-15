//
//  UIViewController+LGONavigationBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+LGONavigationBar.h"

@implementation UIViewController (LGONavigationBar)

- (void)lgo_setNeedsNavigationBarAppearanceUpdate:(BOOL)animated {
    if (self.navigationController != nil) {
        [self.navigationController setNavigationBarHidden:self.lgo_navigationBarHidden animated:animated];
    }
}

static int kNavigationHiddenIdentifierKey;

- (BOOL)lgo_navigationBarHidden {
    return objc_getAssociatedObject(self, &kNavigationHiddenIdentifierKey) == nil ? NO : [objc_getAssociatedObject(self, &kNavigationHiddenIdentifierKey) boolValue];
}

- (void)setLgo_navigationBarHidden:(BOOL)lgo_navigationBarHidden {
    objc_setAssociatedObject(self, &kNavigationHiddenIdentifierKey, @(lgo_navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
