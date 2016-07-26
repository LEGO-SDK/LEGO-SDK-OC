//
//  LGOWatchDog.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWatchDog.h"
#import "LGOCore.h"

@implementation LGOWatchDog

+ (BOOL)checkURL:(NSURL *)URL {
    NSString *host = URL.host;
    if (host != nil) {
        for (NSString *whiteItem in [LGOCore.whiteList copy]) {
            if ([host hasSuffix:whiteItem]) {
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)checkSSL:(NSURL *)URL {
    NSString *host = URL.host;
    if (host != nil) {
        for (NSString *sslItem in [LGOCore.requireSSL copy]) {
            if ([host hasSuffix:sslItem]) {
                if (![URL.scheme isEqualToString:@"https"]) {
                    return NO;
                }
            }
        }
        return YES;
    }
    return NO;
}

+ (BOOL)checkModule:(NSURL *)URL moduleName:(NSString *)moduleName {
    if (![self checkURL:URL]) {
        return false;
    }
    NSString *host = URL.host;
    if (host != nil) {
        NSArray<NSString *> *moduleSettings = LGOCore.whiteModule[moduleName];
        if (moduleSettings != nil) {
            for (NSString *moduleSetting in moduleSettings) {
                if ([host hasSuffix:moduleSetting]) {
                    return YES;
                }
            }
        }
        else {
            return YES;
        }
    }
    return NO;
}

@end
