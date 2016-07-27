//
//  LGOWebHTTPService.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGOWebHTTPService : NSObject

+ (NSURLRequest *)proxyRequest:(NSURLRequest *)originRequest;

- (void)startService;

@end
