//
//  LGOSkeleton.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/7/25.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOSkeleton.h"
#import <WebKit/WebKit.h>

@interface LGOSkeleton ()

@property (nonatomic, assign) BOOL skeletonNotExists;
@property (nonatomic, assign) BOOL skeletonLoaded;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation LGOSkeleton

static BOOL handleDismiss = NO;

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"WebView.Skeleton" instance:[self new]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [(LGOSkeleton *)[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] loadSkeleton];
    });
}

- (void)loadSkeleton {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"skeleton" ofType:@"html"];
    if (filePath != nil) {
        [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL]
                             baseURL:nil];
        self.skeletonLoaded = YES;
    }
    else {
        self.skeletonNotExists = YES;
    }
}

- (void)attachSkeleton:(UIView *)toView URL:(NSURL *)URL {
    if (self.skeletonNotExists) {
        return;
    }
    if (!self.skeletonLoaded) {
        [self loadSkeleton];
    }
    if (self.skeletonLoaded) {
        if (self.webView.loading) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self attachSkeleton:toView URL:URL];
            });
            return;
        }
        [self.webView removeFromSuperview];
        handleDismiss = NO;
        [self.webView evaluateJavaScript:@"handleRequest('%@')" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
            if ([value isKindOfClass:[NSNumber class]]) {
                if ([value boolValue]) {
                    handleDismiss = YES;
                }
            }
        }];
        self.webView.frame = toView.bounds;
        [toView addSubview:self.webView];
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"canHandleRequest('%@')", URL.absoluteString]
                       completionHandler:^(id _Nullable value, NSError * _Nullable error) {
                           BOOL unhandle = YES;
                           if ([value isKindOfClass:[NSNumber class]]) {
                               if ([value boolValue]) {
                                   unhandle = NO;
                               }
                           }
                           if (unhandle) {
                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                   [self.webView removeFromSuperview];
                               }];
                           }
                       }];
    }
}

- (void)dismiss:(BOOL)force {
    if (!force && handleDismiss) {
        return;
    }
    [UIView animateWithDuration:0.30 animations:^{
        self.webView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.webView removeFromSuperview];
        self.webView.alpha = 1.0;
    }];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    if ([dictionary[@"opt"] isKindOfClass:[NSString class]] && [dictionary[@"opt"] isEqualToString:@"dismiss"]) {
        [self dismiss:YES];
    }
    return nil;
}

- (WKWebView *)webView {
    if (_webView == nil) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.userInteractionEnabled = NO;
    }
    return _webView;
}

@end
