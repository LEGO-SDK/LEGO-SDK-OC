//
//  LGOWebService.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LGOWebCachePolicy : NSObject

@property (nonatomic, assign) NSURLRequestCachePolicy policy;
@property (nonatomic, assign) int time;

- (instancetype)initWithPolicy:(NSURLRequestCachePolicy)policy time:(int)time;

@end

@interface LGOWebService : NSObject

- (void)startService;

- (BOOL)cachedForRequest:(NSURLRequest *)request;

- (BOOL)experiedForRequest:(NSURLRequest *)request second:(NSNumber *)second;

- (void)updateCacheWithRequest:(NSURLRequest *)request;

- (NSString *)filePathWithRequest:(NSURLRequest *)request;

- (LGOWebCachePolicy *)cachePolicyForRequest:(NSURLRequest *)request;

@end
