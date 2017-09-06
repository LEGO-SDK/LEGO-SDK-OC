//
//  LGOSnapshot.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/8/9.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOSnapshot.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LGOSkeletonSnapshot

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

+ (NSString *)snapshotCacheKey:(NSURL *)URL {
    NSString *str = [NSString stringWithFormat:@"%@.%@.%@.png",
                     URL.absoluteString,
                     [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                     [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    return [LGOSkeletonSnapshot requestMD5WithString:str];
}

+ (NSString *)snapshotCachePath:(NSURL *)URL {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachePath = [NSString stringWithFormat:@"%@/LGOSkeleton/%@", cacheDir, [self snapshotCacheKey: URL]];
    return cachePath;
}

+ (BOOL)snapshotExists:(NSURL *)URL {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self snapshotCachePath: URL]];
}

@end

@implementation LGOSkeletonSnapshotRequest

@end

@implementation LGOSkeletonSnapshotOperation

static NSArray *snapshotOperationQueue;
static LGOSkeletonSnapshotOperation *currentOperation;

- (NSString *)snapshotCacheKey {
    return [LGOSkeletonSnapshot snapshotCacheKey:[NSURL URLWithString:self.request.targetURL]];
}

- (NSString *)snapshotCachePath {
    return [LGOSkeletonSnapshot snapshotCachePath:[NSURL URLWithString:self.request.targetURL]];
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
        if (self.request.targetURL == nil ||
            self.request.snapshotURL == nil ||
            [NSURL URLWithString:self.request.targetURL] == nil ||
            [NSURL URLWithString:self.request.snapshotURL] == nil) {
            return ;
        }
        else {
            if ([LGOSkeletonSnapshot snapshotExists:[NSURL URLWithString:self.request.snapshotURL]]) {
                NSData *data = [NSData dataWithContentsOfFile:[LGOSkeletonSnapshot snapshotCachePath:[NSURL URLWithString:self.request.snapshotURL]]];
                if (data != nil) {
                    [data writeToFile:[LGOSkeletonSnapshot snapshotCachePath:[NSURL URLWithString:self.request.targetURL]] atomically:YES];
                    [self doNext];
                    return;
                }
            }
            if (![self exists]) {
                self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(9999, 9999, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
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
        if ([webView drawViewHierarchyInRect:webView.bounds afterScreenUpdates:NO]) {
            UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (snapshotImage != nil) {
                NSData *imageData = UIImagePNGRepresentation(snapshotImage);
                if (imageData != nil) {
                    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
                    [[NSFileManager defaultManager] createDirectoryAtPath:[cacheDir stringByAppendingString:@"/LGOSkeleton"] withIntermediateDirectories:YES attributes:nil error:NULL];
                    [imageData writeToFile:[self snapshotCachePath] atomically:YES];
                    [imageData writeToFile:[LGOSkeletonSnapshot snapshotCachePath:[NSURL URLWithString:self.request.snapshotURL]] atomically:YES];
                }
            }
        }
        else {
            UIGraphicsEndImageContext();
        }
        [UIView setAnimationsEnabled:YES];
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
