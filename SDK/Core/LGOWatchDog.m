//
//  LGOWatchDog.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOWatchDog.h"

@implementation LGOWatchDog

+ (BOOL)checkURL:(NSURL *)URL {
    if ([LGOCore.whiteList count] == 0) {
        return YES;
    }
    NSString *host = URL.host;
    if (host != nil) {
        for (NSString *whiteItem in [LGOCore.whiteList copy]) {
            if ([host hasSuffix:whiteItem]) {
                return YES;
            }
        }
    }
    else {
        for (NSString *whiteItem in [LGOCore.whiteList copy]) {
            if ([URL.absoluteString hasPrefix:whiteItem]) {
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)checkSSL:(NSURL *)URL {
    if ([LGOCore.requireSSL count] == 0) {
        return YES;
    }
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
        return NO;
    }
    NSString *host = URL.host;
    if (host == nil && [LGOCore.whiteList count] == 0) {
        return YES;
    } else if (host != nil) {
        NSArray<NSString *> *moduleSettings = LGOCore.whiteModule[moduleName];
        if (moduleSettings != nil) {
            for (NSString *moduleSetting in moduleSettings) {
                if ([host hasSuffix:moduleSetting]) {
                    return YES;
                }
            }
        } else {
            return YES;
        }
    }
    return NO;
}

@end
