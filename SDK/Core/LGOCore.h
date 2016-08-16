//
//  LGOCore.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGOModules.h"

@interface LGOCore : NSObject

+ (NSString *)SDKVersion;

+ (NSMutableArray<NSString *> *)whiteList;

+ (NSMutableArray<NSString *> *)requireSSL;

+ (NSMutableDictionary<NSString *, NSArray<NSString *> *> *)whiteModule;

+ (LGOModules *)modules;

@end
