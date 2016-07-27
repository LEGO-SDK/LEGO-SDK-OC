//
//  LGOWebCache.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGOWebHTTPService.h"
#import "LGOWebService.h"

@interface LGOWebCache : NSObject

@property (nonatomic, readonly) NSDictionary *cacheConfiguration;
@property (nonatomic, readonly) LGOWebHTTPService *HTTPService;
@property (nonatomic, readonly) LGOWebService *webService;

- (void)startService;

- (NSString *)workerPath;

@end
