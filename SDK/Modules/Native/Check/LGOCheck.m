//
//  LGOCheck.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCheck.h"
#import "LGOCore.h"

@interface LGOCheckRequest : LGORequest

@end

@implementation LGOCheckRequest

@end

@interface LGOCheckResponse : LGOResponse

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *checkResult;

@end

@implementation LGOCheckResponse

- (NSDictionary *)resData {
    if (self.checkResult == nil) {
        return @{};
    }
    return @{ @"SDKVersion" : [LGOCore SDKVersion], @"checkResult" : self.checkResult };
}

@end

@interface LGOCheckOperation : LGORequestable

@property(nonatomic, strong) LGOCheckRequest *request;

@end

@implementation LGOCheckOperation

- (LGOResponse *)requestSynchronize {
    NSMutableDictionary *checkResult = [NSMutableDictionary dictionary];
    for (NSString *module in [[LGOCore modules] allModules]) {
        [checkResult setObject:[NSNumber numberWithBool:YES] forKey:module];
    }
    LGOCheckResponse *response = [[LGOCheckResponse alloc] init];
    response.checkResult = checkResult;
    return [response accept:nil];
}

@end

@implementation LGOCheck

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.Check" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOCheckRequest class]]) {
        LGOCheckOperation *operation = [LGOCheckOperation new];
        operation.request = (LGOCheckRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.Check" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOCheckRequest *request = [[LGOCheckRequest alloc] initWithContext:context];
    LGOCheckOperation *operation = [LGOCheckOperation new];
    operation.request = request;
    return operation;
}

- (NSDictionary *)synchronizeResponse:(UIView *)webView {
    NSMutableDictionary *checkResult = [NSMutableDictionary dictionary];
    for (NSString *moduleName in LGOCore.modules.allModules) {
        LGOModule *moduleInstance = [[LGOCore modules] moduleWithName:moduleName];
        [checkResult setObject:[NSNumber numberWithInteger:moduleInstance.ver] forKey:moduleName];
    }
    LGOCheckResponse *response = [[LGOCheckResponse alloc] init];
    response.checkResult = [checkResult copy];
    return [[response accept:nil] resData];
}

@end