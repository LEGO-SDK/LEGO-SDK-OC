//
//  WKWebView+LGOAutoInject.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "WKWebView+LGOAutoInject.h"
#import "LGOJavaScriptUserContentController.h"

@implementation WKWebView (LGOAutoInject)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            SEL originalSelector = @selector(initWithFrame:configuration:);
            SEL swizzledSelector = @selector(initWithLGOAutoInjectFrame:configuration:);
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

- (instancetype)initWithLGOAutoInjectFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    LGOJavaScriptUserContentController *userContentController = [[LGOJavaScriptUserContentController alloc] init];
    configuration.userContentController = userContentController;
    self = [self initWithLGOAutoInjectFrame:frame configuration:configuration];
    if (self) {
        userContentController.webView = self;
    }
    return self;
}

@end
