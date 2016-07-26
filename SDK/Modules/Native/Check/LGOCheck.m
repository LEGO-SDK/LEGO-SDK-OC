//
//  LGOCheck.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCheck.h"
#import "LGOCore.h"

@interface LGOCheckResponse : LGOResponse

@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *checkResult;

@end

@implementation LGOCheckResponse

- (NSDictionary *)toDictionary {
    return @{
             @"succeed": [NSNumber numberWithBool:YES],
             @"checkResult": self.checkResult
             };
}

@end

@interface LGOCheckOperation : LGORequestable

@end

@implementation LGOCheckOperation

- (LGOResponse *)requestSynchronize {
    NSMutableDictionary *checkResult = [NSMutableDictionary dictionary];
    for (NSString *module in [[LGOCore modules] allModules]) {
        [checkResult setObject:[NSNumber numberWithBool:YES] forKey:module];
    }
    LGOCheckResponse *response = [[LGOCheckResponse alloc] init];
    response.checkResult = checkResult;
    return response;
}

@end

@implementation LGOCheck

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    return [[LGOCheckOperation alloc] init];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    return [[LGOCheckOperation alloc] init];
}

@end