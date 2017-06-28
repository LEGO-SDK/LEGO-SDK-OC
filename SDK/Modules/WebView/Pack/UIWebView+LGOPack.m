//
//  UIWebView+LGOPack.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "LGOPack.h"
#import "LGOWatchDog.h"
#import "UIWebView+LGOPack.h"

@implementation UIWebView (LGOPack)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          Class class = [UIWebView class];
          SEL originalSelector = @selector(loadRequest:);
          SEL swizzledSelector = @selector(lgo_PackLoadRequest:);
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)lgo_PackLoadRequest:(NSURLRequest *)request {
    if ([[request.URL lastPathComponent] hasSuffix:@".zip"]) {
        NSURL *zipURL = [NSURL URLWithString:[[request.URL.absoluteString componentsSeparatedByString:@"?"] firstObject]];
        NSString *zipInnerPath = [request.URL.absoluteString rangeOfString:@"?"].location != NSNotFound ?
        [[request.URL.absoluteString componentsSeparatedByString:@"?"] lastObject] : nil;
        if (![LGOWatchDog checkURL:zipURL] || ![LGOWatchDog checkSSL:zipURL]) {
            return [self lgo_PackLoadRequest:request];
        }
        __block BOOL loaded = NO;
        [LGOPack createFileServerWithURL:zipURL progressBlock:^(double progress) {
            
        } completionBlock:^(NSString *finalPath) {
            if (zipInnerPath != nil) {
                finalPath = [finalPath stringByAppendingString:zipInnerPath];
            }
            else {
                finalPath = [finalPath stringByAppendingString:@"index.html"];
            }
            [self lgo_PackLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalPath]]];
            loaded = YES;
        }];
        if (loaded) {
            return;
        }
        return [self lgo_PackLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
    return [self lgo_PackLoadRequest:request];
}
#pragma clang diagnostic pop

@end
