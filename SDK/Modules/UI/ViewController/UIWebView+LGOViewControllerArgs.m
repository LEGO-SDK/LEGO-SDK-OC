//
//  UIWebView+LGOViewControllerArgs.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "UIWebView+LGOViewControllerArgs.h"

@implementation UIWebView (LGOViewControllerArgs)

static int kArgsIdentifierKey;

- (NSDictionary *)lgo_args {
    return objc_getAssociatedObject(self, &kArgsIdentifierKey);
}

- (void)setLgo_args:(NSDictionary *)lgo_args {
    objc_setAssociatedObject(self, &kArgsIdentifierKey, lgo_args, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
