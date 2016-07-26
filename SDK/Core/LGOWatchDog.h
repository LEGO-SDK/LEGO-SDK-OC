//
//  LGOWatchDog.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGOWatchDog : NSObject

+ (BOOL)checkURL:(NSURL *)URL;

+ (BOOL)checkSSL:(NSURL *)URL;

+ (BOOL)checkModule:(NSURL *)URL moduleName:(NSString *)moduleName;

@end
