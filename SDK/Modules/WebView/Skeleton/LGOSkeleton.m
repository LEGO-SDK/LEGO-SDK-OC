//
//  LGOSkeleton.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/7/25.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOSkeleton.h"
#import "LGOWKWebView.h"
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface LGOSkeleton ()

@property (nonatomic, assign) BOOL skeletonNotExists;
@property (nonatomic, assign) BOOL skeletonLoaded;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIImageView *snapshotImageView;

@end

@interface LGOSkeletonSnapshotRequest : LGORequest

@property (nonatomic, copy) NSString *targetURL;
@property (nonatomic, copy) NSString *snapshotURL;

@end

@implementation LGOSkeletonSnapshotRequest

@end

@interface LGOSkeletonSnapshotOperation : LGORequestable<WKNavigationDelegate>

@property (nonatomic, strong) LGOSkeletonSnapshotRequest *request;
@property (nonatomic, strong) LGOWKWebView *webView;

@end

@implementation LGOSkeletonSnapshotOperation

static NSArray *snapshotOperationQueue;
static LGOSkeletonSnapshotOperation *currentOperation;

- (NSString *)snapshotCacheKey {
    NSString *str = [NSString stringWithFormat:@"%@.%@.%@.png",
                     self.request.targetURL,
                     [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                     [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    return [LGOSkeletonSnapshotOperation requestMD5WithString:str];
}

- (NSString *)snapshotCachePath {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachePath = [NSString stringWithFormat:@"%@/LGOSkeleton/%@", cacheDir, [self snapshotCacheKey]];
    return cachePath;
}

- (BOOL)exists {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self snapshotCachePath]];
}

- (LGOResponse *)requestSynchronize {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (currentOperation != nil) {
            if ([snapshotOperationQueue indexOfObject:self] == NSNotFound) {
                NSMutableArray *queue = [snapshotOperationQueue mutableCopy] ?: [NSMutableArray array];
                [queue addObject:self];
                snapshotOperationQueue = [queue copy];
            }
            return ;
        }
        else {
            currentOperation = self;
        }
        if (self.request.targetURL == nil || self.request.snapshotURL == nil) {
            return ;
        }
        else {
            if (![self exists]) {
                self.webView = [[LGOWKWebView alloc] initWithFrame:CGRectMake(9999, 9999, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                [self.webView setNavigationDelegate:self];
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.request.snapshotURL]]];
                self.webView.userInteractionEnabled = NO;
                [[UIApplication sharedApplication].keyWindow insertSubview:self.webView atIndex:0];
                __weak id welf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __strong id strongSelf = welf;
                    if (strongSelf != nil) {
                        self.webView.navigationDelegate = nil;
                        [self.webView removeFromSuperview];
                    }
                });
            }
            else {
                [self doNext];
            }
        }
    });
    return [[LGOResponse new] accept:nil];
}

- (void)doNext {
    currentOperation = nil;
    NSMutableArray *queue = [snapshotOperationQueue mutableCopy] ?: [NSMutableArray array];
    [queue removeObject:self];
    LGOSkeletonSnapshotOperation *nextOperation = [queue firstObject];
    if (nextOperation != nil) {
        [queue removeObjectAtIndex:0];
    }
    snapshotOperationQueue = [queue copy];
    if (nextOperation) {
        [nextOperation requestSynchronize];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContextWithOptions(webView.bounds.size, YES, [UIScreen mainScreen].scale);
        [webView drawViewHierarchyInRect:webView.bounds afterScreenUpdates:YES];
        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (snapshotImage != nil) {
            NSData *imageData = UIImagePNGRepresentation(snapshotImage);
            if (imageData != nil) {
                NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
                [[NSFileManager defaultManager] createDirectoryAtPath:[cacheDir stringByAppendingString:@"/LGOSkeleton"] withIntermediateDirectories:YES attributes:nil error:NULL];
                [imageData writeToFile:[self snapshotCachePath] atomically:YES];
            }
        }
        self.webView.navigationDelegate = nil;
        [self.webView removeFromSuperview];
        [self doNext];
    });
}

+ (NSString *)requestMD5WithString:(NSString *)str
{
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return [digest lowercaseString];
}

@end

@implementation LGOSkeleton

static BOOL handleDismiss = NO;

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"WebView.Skeleton" instance:[self new]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [(LGOSkeleton *)[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] loadSkeleton];
    });
}

- (NSString *)snapshotCacheKey:(NSURL *)URL {
    NSString *str = [NSString stringWithFormat:@"%@.%@.%@.png",
                     URL.absoluteString,
                     [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                     [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    return [LGOSkeletonSnapshotOperation requestMD5WithString:str];
}

- (NSString *)snapshotCachePath:(NSURL *)URL {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachePath = [NSString stringWithFormat:@"%@/LGOSkeleton/%@", cacheDir, [self snapshotCacheKey: URL]];
    return cachePath;
}

- (BOOL)snapshotExists:(NSURL *)URL {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self snapshotCachePath: URL]];
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
    if ([self snapshotExists:URL]) {
        UIImage *snapshot = [UIImage imageWithContentsOfFile:[self snapshotCachePath:URL]];
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
