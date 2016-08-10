//
//  LGOCall.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCall.h"
#import "LGOWebViewController.h"
#import "LGOBuildFailed.h"

// Request
@interface LGOCallRequest : LGORequest

@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, copy) NSDictionary *userInfo;

@end


@implementation LGOCallRequest

- (instancetype)initWithContext:(LGORequestContext *)context methodName:(NSString *)methodName userInfo:(NSDictionary *)userInfo {
    self = [super initWithContext: context];
    if (self) {
        _methodName = methodName;
        _userInfo = userInfo;
    }
    return self;
}

@end

// Operation

@interface LGOCallOperation : LGORequestable

@property (nonatomic, strong) LGOCallRequest *request;

@end

@implementation LGOCallOperation

- (LGOResponse *)requestSynchronize {
    UIViewController *requestViewController = self.request.context.requestViewController;
    if ([requestViewController isKindOfClass:[LGOWebViewController class]]) {
        [(LGOWebViewController *)requestViewController callWithMethodName:self.request.methodName userInfo:self.request.userInfo];
        return [[LGOResponse alloc] init];
    }
    return [[LGOBuildFailedResponse alloc] initWithErrorString: @"DownCast Failed"];
}

@end


// Module

@implementation LGOCall

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ( [request isKindOfClass:[LGOCallRequest class]] ) {
        LGOCallOperation *operation = [LGOCallOperation new];
        operation.request = (LGOCallRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *methodName = [dictionary[@"selectorName"] isKindOfClass:[NSString class]] ? dictionary[@"selectorName"] : nil;
    NSDictionary *userInfo = [dictionary[@"userInfo"] isKindOfClass:[NSDictionary class]] ? dictionary[@"userInfo"] : nil;
    LGOCallRequest *request = [[LGOCallRequest alloc] initWithContext:context methodName:methodName userInfo:userInfo];
    
    LGOCallOperation *operation = [LGOCallOperation new];
    operation.request = request;
    return operation;
}

@end




