//
//  LGOWebCache.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebCache.h"
#import "LGOCore.h"

@interface LGOWebCache ()

@property (nonatomic, copy) NSDictionary *cacheConfiguration;
@property (nonatomic, readwrite) LGOWebService *webService;

@end

@implementation LGOWebCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _webService = [[LGOWebService alloc] init];
    }
    return self;
}

- (void)startService {
    [[LGOCore whiteList] addObject:@"localhost"];
    NSString *bundlePath = [self bundlePath];
    NSString *workerPath = [self workerPath];
    if (bundlePath != nil && workerPath != nil) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:workerPath]) {
            NSError *err;
            [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:workerPath error:&err];
            if (err == nil) {
                [self updateConfiguration];
                [self.webService startService];
            }
            else {
                NSLog(@"%@", err);
            }
        }
        else {
            [self updateConfiguration];
            [self.webService startService];
        }
    }
}

- (NSString *)bundlePath {
    return [[NSBundle mainBundle] pathForResource:@"LGOCache" ofType:@"bundle"];
}

- (NSString *)workerPath {
    NSString *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    if (cachesDir != nil) {
        return [NSString stringWithFormat:@"%@/LGOCache_%@.bundle/", cachesDir, [self appBundleVersion]];
    }
    return nil;
}

- (void)updateConfiguration {
    NSString *workerPath = [self workerPath];
    if (workerPath != nil) {
        NSData *data = [NSData dataWithContentsOfFile:[workerPath stringByAppendingString:@"config.json"]];
        if (data != nil) {
            NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (configuration != nil && [configuration isKindOfClass:[NSDictionary class]]) {
                self.cacheConfiguration = configuration;
            }
        }
    }
}

- (NSString *)appBundleVersion {
    NSString *bundleVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    if ([bundleVersion isKindOfClass:[NSString class]]) {
        return bundleVersion;
    }
    else {
        return @"0";
    }
}

@end
