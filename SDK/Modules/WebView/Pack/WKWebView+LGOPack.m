//
//  WKWebView+LGOPack.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "LGOWatchDog.h"
#import "LGOPack.h"
#import "WKWebView+LGOPack.h"

@implementation WKWebView (LGOPack)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [WKWebView class];
            SEL originalSelector = @selector(loadRequest:);
            SEL swizzledSelector = @selector(lgo_PackLoadRequest:);
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (WKNavigation *)lgo_PackLoadRequest:(NSURLRequest *)request {
    if ([[request.URL lastPathComponent] hasSuffix:@".zip"]) {
        if (![LGOWatchDog checkURL:request.URL] || ![LGOWatchDog checkSSL:request.URL]) {
            return [self lgo_PackLoadRequest:request];
        }
        if ([LGOPack localCachedWithURL:request.URL]) {
            if ([self respondsToSelector:NSSelectorFromString(@"lgo_progressView")]) {
                NSObject *progressView = [self performSelector:NSSelectorFromString(@"lgo_progressView")];
                if ([progressView respondsToSelector:NSSelectorFromString(@"progressView")]) {
                    UIView *view = [progressView performSelector:NSSelectorFromString(@"progressView")];
                    if ([view isKindOfClass:[UIView class]]) {
                        [view setHidden:YES];
                    }
                }
            }
            [LGOPack createFileServerWithURL:request.URL progressBlock:^(double progress) {} completionBlock:^(NSString *finalPath) {
                [self lgo_PackLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalPath]]];
            }];
        }
        else {
            [LGOPack createFileServerWithURL:request.URL progressBlock:^(double progress) {} completionBlock:^(NSString *finalPath) {
                [self lgo_PackLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalPath]]];
            }];
        }
        return [self lgo_PackLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
    return [self lgo_PackLoadRequest:request];
}
#pragma clang diagnostic pop

@end
