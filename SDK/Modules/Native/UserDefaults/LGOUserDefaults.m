//
//  LGOUserDefaults.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOUserDefaults.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"

// Request
@interface LGOUserDefaultsRequest : LGORequest
@property (nonatomic, strong) NSString * suite;
@property (nonatomic, strong) NSString * opt; // create/update/read/delete
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) id _Nullable value;
@end

@implementation LGOUserDefaultsRequest

- (instancetype)initWithSuite:(NSString *)suite opt:(NSString *)opt key:(NSString *)key value:(id)value {
    self = [super init];
    if (self) {
        _suite = suite;
        _opt = opt;
        _key = key;
        _value = value;
    }
    return self;
}

@end

// Response
@interface LGOUserDefaultsResponse : LGOResponse
@property (nonatomic, strong) id value;
@end

@implementation LGOUserDefaultsResponse

- (instancetype)initWithSucceed:(BOOL)succeed value:(id)value{
    self = [super init];
    if (self) {
        self.succeed = succeed;
        _value = value;
    }
    return self;
}

- (NSDictionary *)toDictionary{
    return @{
             @"succeed": [NSNumber numberWithBool:self.succeed],
             @"value": self.value
             };
}

@end

// Operation
@interface LGOUserDefaultsOperation : LGORequestable
@property (nonatomic, strong) LGOUserDefaultsRequest *request;
@end

@implementation LGOUserDefaultsOperation

- (NSUserDefaults *) userDefault{
    if (self.request.suite.length > 0){
        return [[NSUserDefaults alloc] initWithSuiteName:self.request.suite];
    }
    return [NSUserDefaults standardUserDefaults];
}

- (LGOResponse *)requestSynchronize{
    if ([self.request.opt isEqualToString:@"create"] || [self.request.opt isEqualToString:@"update"]) {
        if ([self.request.value isKindOfClass:[NSString class]] || [self.request.value isKindOfClass:[NSNumber class]]){
            [[self userDefault] setValue:self.request.value forKey:self.request.key];
            return [[LGOUserDefaultsResponse alloc] initWithSucceed:YES value:@""];
        }
        return [[LGOUserDefaultsResponse alloc] initWithSucceed:NO value:@""];
    }
    else if ([self.request.opt isEqualToString:@"read"]){
        id value = [[self userDefault] objectForKey:self.request.key];
        if (value) {
            return [[LGOUserDefaultsResponse alloc] initWithSucceed:YES value:value];
        }
        return [[LGOUserDefaultsResponse alloc] initWithSucceed:NO value:@""];
    }
    else if ([self.request.opt isEqualToString:@"delete"]){
        [[self userDefault] removeObjectForKey:self.request.key];
        return [[LGOUserDefaultsResponse alloc] initWithSucceed:YES value:@""];
    }
    return [[LGOUserDefaultsResponse alloc] initWithSucceed:NO value:@""];
}

@end

// Module
@implementation LGOUserDefaults

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOUserDefaultsRequest class]]){
        LGOUserDefaultsOperation *operation = [LGOUserDefaultsOperation new];
        operation.request = (LGOUserDefaultsRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSString * opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : nil;
    NSString * key = [dictionary[@"key"] isKindOfClass:[NSString class]] ? dictionary[@"key"] : nil;
    if (opt && key) {
        NSString * suite = [dictionary[@"suite"] isKindOfClass:[NSString class]] ? dictionary[@"suite"] : @"";
        return [self buildWithRequest:[[LGOUserDefaultsRequest alloc] initWithSuite:suite opt:opt key:key value:dictionary[@"value"]]];
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: opt, key"];
}

@end




