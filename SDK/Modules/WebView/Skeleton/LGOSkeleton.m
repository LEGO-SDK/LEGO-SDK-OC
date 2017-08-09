//
//  LGOSkeleton.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/7/25.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOSkeleton.h"
#import "LGOSnapshot.h"
#import <CommonCrypto/CommonDigest.h>

@interface LGOSkeleton ()

@property (nonatomic, assign) BOOL skeletonNotExists;
@property (nonatomic, assign) BOOL skeletonLoaded;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIImageView *snapshotImageView;

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
    if ([LGOSkeletonSnapshot snapshotExists:URL]) {
        UIImage *snapshot = [UIImage imageWithContentsOfFile:[LGOSkeletonSnapshot snapshotCachePath:URL]];
        if (snapshot != nil && snapshot.size.width > 0 && snapshot.size.height > 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = snapshot;
            [toView addSubview:imageView];
            [toView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[iv]-0-|" options:kNilOptions metrics:@{} views:@{@"iv": imageView}]];
            [toView addConstraint:[NSLayoutConstraint constraintWithItem:toView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
            [toView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:snapshot.size.width / snapshot.size.height constant:0.0]];
            self.snapshotImageView = imageView;
            return;
        }
    }
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
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"handleRequest('%@')", URL.absoluteString] completionHandler:^(id _Nullable value, NSError * _Nullable error) {
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
    [UIView animateWithDuration:0.30 delay:0.15 options:kNilOptions animations:^{
        self.webView.alpha = 0.0;
        self.snapshotImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.webView removeFromSuperview];
        [self.snapshotImageView removeFromSuperview];
        self.snapshotImageView = nil;
        self.webView.alpha = 1.0;
    }];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    if ([dictionary[@"opt"] isKindOfClass:[NSString class]] && [dictionary[@"opt"] isEqualToString:@"dismiss"]) {
        [self dismiss:YES];
    }
    if (([UIDevice currentDevice].systemVersion.floatValue >= 8.0) && [dictionary[@"opt"] isKindOfClass:[NSString class]] && [dictionary[@"opt"] isEqualToString:@"snapshot"]) {
        LGOSkeletonSnapshotRequest *request = [LGOSkeletonSnapshotRequest new];
        request.targetURL = [dictionary[@"targetURL"] isKindOfClass:[NSString class]] ? dictionary[@"targetURL"] : nil;
        request.snapshotURL = [dictionary[@"snapshotURL"] isKindOfClass:[NSString class]] ? dictionary[@"snapshotURL"] : nil;
        LGOSkeletonSnapshotOperation *operation = [LGOSkeletonSnapshotOperation new];
        operation.request = request;
        return operation;
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
