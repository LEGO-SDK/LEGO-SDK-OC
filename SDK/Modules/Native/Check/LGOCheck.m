//
//  LGOCheck.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCheck.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"

// - Request

@interface LGOCheckRequest : LGORequest

@property (nonatomic, copy) NSArray *moduleList;

@end

@implementation LGOCheckRequest

@end

// - Response

@interface LGOCheckResponse : LGOResponse

@property (nonatomic, retain) NSDictionary<NSString *, NSNumber *> *checkResult;

@end

@implementation LGOCheckResponse

- (NSDictionary *)toDictionary {
    return @{
             @"SDKVersion": [LGOCore SDKVersion],
             @"checkResult": self.checkResult
             };
}

@end

// - Operation

@interface LGOCheckOperation : LGORequestable
@property (nonatomic, strong) LGOCheckRequest *request;
@end

@implementation LGOCheckOperation

- (LGOResponse *)requestSynchronize {
    NSMutableDictionary *checkResult = [NSMutableDictionary dictionary];
    for (NSString *module in self.request.moduleList) {
        [checkResult setObject:[NSNumber numberWithBool:YES] forKey:module];
    }
    LGOCheckResponse *response = [[LGOCheckResponse alloc] init];
    response.checkResult = checkResult;
    return response;
}

@end

// - Module

@implementation LGOCheck

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ( [request isKindOfClass:[LGOCheckRequest class]] ) {
        LGOCheckOperation *operation = [LGOCheckOperation new];
        operation.request = (LGOCheckRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOCheckRequest *request = [[LGOCheckRequest alloc] initWithContext:context];
    NSArray *moduleList = [dictionary[@"moduleList"] isKindOfClass:[NSArray<NSString *> class]] ? dictionary[@"moduleList"] : @[];
    if (moduleList.count) {
        request.moduleList = moduleList;
    }
    else {
        request.moduleList = LGOCore.modules.allModules;
    }
    
    LGOCheckOperation *operation = [LGOCheckOperation new];
    operation.request = request;
    return operation;
}

@end