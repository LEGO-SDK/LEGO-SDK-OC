//
//  UIWebView+LGOAutoInject.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSContext+LGOProps.h"
#import "LGOJavaScriptBridge.h"
#import "UIWebView+LGOAutoInject.h"

@implementation UIWebView (LGOAutoInject)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            SEL originalSelector = @selector(initWithCoder:);
            SEL swizzledSelector = @selector(initWithLGOAutoInjectCoder:);
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
            Class class = [self class];
            SEL originalSelector = @selector(initWithFrame:);
            SEL swizzledSelector = @selector(initWithLGOAutoInjectFrame:);
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

- (instancetype)initWithLGOAutoInjectFrame:(CGRect)frame {
    self = [self initWithLGOAutoInjectFrame:frame];
    if (self) {
        [self lgo_configureContext];
    }
    return self;
}

- (instancetype)initWithLGOAutoInjectCoder:(NSCoder *)coder {
    self = [self initWithLGOAutoInjectCoder:coder];
    if (self) {
        [self lgo_configureContext];
    }
    return self;
}

- (void)lgo_configureContext {
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (context != nil && context != self.lgo_context) {
        context.lgo_webView = self;
        [LGOJavaScriptBridge configureWithJSContext:context];
        self.lgo_context = context;
    }
}

static int kContextIdentifierKey;

- (JSContext *)lgo_context {
    return objc_getAssociatedObject(self, &kContextIdentifierKey);
}

- (void)setLgo_context:(JSContext *)lgo_context {
    objc_setAssociatedObject(self, &kContextIdentifierKey, lgo_context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
