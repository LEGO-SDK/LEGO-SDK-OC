//
//  LGOCore.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"

@implementation LGOCore

+ (NSString *)SDKVersion {
    return @"0.2.3";
}

+ (NSMutableArray<NSString *> *)whiteList {
    static NSMutableArray *arr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arr = [NSMutableArray array];
    });
    return arr;
}

+ (NSMutableArray<NSString *> *)requireSSL {
    static NSMutableArray *arr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arr = [NSMutableArray array];
    });
    return arr;
}

+ (NSMutableDictionary<NSString *,NSArray<NSString *> *> *)whiteModule {
    static NSMutableDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary dictionary];
    });
    return dict;
}

+ (LGOModules *)modules {
    static LGOModules *modules;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modules = [[LGOModules alloc] init];
    });
    return modules;
}

@end
