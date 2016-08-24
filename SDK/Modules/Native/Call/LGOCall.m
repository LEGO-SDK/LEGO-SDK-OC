//
//  LGOCall.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCall.h"
#import "LGOCallable.h"
#import "LGOCore.h"

@interface LGOCallRequest : LGORequest

@property(nonatomic, copy) NSString *methodName;
@property(nonatomic, copy) NSDictionary *userInfo;

@end

@implementation LGOCallRequest

- (instancetype)initWithContext:(LGORequestContext *)context
                     methodName:(NSString *)methodName
                       userInfo:(NSDictionary *)userInfo {
    self = [super initWithContext:context];
    if (self) {
        _methodName = methodName;
        _userInfo = userInfo;
    }
    return self;
}

@end

@interface LGOCallOperation : LGORequestable

@property(nonatomic, strong) LGOCallRequest *request;

@end

@implementation LGOCallOperation

- (LGOResponse *)requestSynchronize {
    UIViewController *requestViewController = self.request.context.requestViewController;
    if ([requestViewController conformsToProtocol:@protocol(LGOCallable)]) {
        [(NSObject<LGOCallable> *)requestViewController callWithMethodName:self.request.methodName
                                                                  userInfo:self.request.userInfo];
        return [[LGOResponse new] accept:nil];
    }
    return [[LGOResponse new]
        reject:[NSError errorWithDomain:@"Native.Call"
                                   code:-3
                               userInfo:@{
                                   NSLocalizedDescriptionKey : @"ViewController Does not conforms LGOCallable."
                               }]];
}

@end

@implementation LGOCall

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.Call" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOCallRequest class]]) {
        LGOCallOperation *operation = [LGOCallOperation new];
        operation.request = (LGOCallRequest *)request;
        return operation;
    }
    return [LGOCallOperation rejectWithDomain:@"Native.Call" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *methodName =
        [dictionary[@"selectorName"] isKindOfClass:[NSString class]] ? dictionary[@"selectorName"] : nil;
    NSDictionary *userInfo =
        [dictionary[@"userInfo"] isKindOfClass:[NSDictionary class]] ? dictionary[@"userInfo"] : nil;
    LGOCallRequest *request = [[LGOCallRequest alloc] initWithContext:context methodName:methodName userInfo:userInfo];
    LGOCallOperation *operation = [LGOCallOperation new];
    operation.request = request;
    return operation;
}

@end
