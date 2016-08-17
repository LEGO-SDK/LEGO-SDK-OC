//
//  LGOUserDefaults.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOUserDefaults.h"

@interface LGOUserDefaultsRequest : LGORequest

@property(nonatomic, strong) NSString *suite;
@property(nonatomic, strong) NSString *opt;  // create/update/read/delete
@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) id _Nullable value;

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

@interface LGOUserDefaultsResponse : LGOResponse

@property(nonatomic, strong) id value;

@end

@implementation LGOUserDefaultsResponse

- (instancetype)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (NSDictionary *)resData {
    return @{ @"value" : self.value != nil ? self.value : [NSNull null] };
}

@end

@interface LGOUserDefaultsOperation : LGORequestable

@property(nonatomic, strong) LGOUserDefaultsRequest *request;

@end

@implementation LGOUserDefaultsOperation

- (NSUserDefaults *)userDefault {
    if (self.request.suite.length > 0) {
        return [[NSUserDefaults alloc] initWithSuiteName:self.request.suite];
    }
    return [NSUserDefaults standardUserDefaults];
}

- (LGOResponse *)requestSynchronize {
    if ([self.request.opt isEqualToString:@"create"] || [self.request.opt isEqualToString:@"update"]) {
        if ([self.request.value isKindOfClass:[NSString class]] ||
            [self.request.value isKindOfClass:[NSNumber class]]) {
            [[self userDefault] setValue:self.request.value forKey:self.request.key];
            return [[LGOResponse new] accept:nil];
        }
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.UserDefaults"
                                                             code:-3
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"Invalid value."
                                                         }]];

    } else if ([self.request.opt isEqualToString:@"read"]) {
        id value = [[self userDefault] objectForKey:self.request.key];
        if (value != nil) {
            return [[[LGOUserDefaultsResponse alloc] initWithValue:value] accept:nil];
        }
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.UserDefaults"
                                                             code:-4
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"Value is empty."
                                                         }]];

    } else if ([self.request.opt isEqualToString:@"delete"]) {
        [[self userDefault] removeObjectForKey:self.request.key];
        return [[LGOResponse new] accept:nil];
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.UserDefaults"
                                                             code:-5
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"Invalid opt value."
                                                         }]];
    }
}

@end

@implementation LGOUserDefaults

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.UserDefaults" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOUserDefaultsRequest class]]) {
        LGOUserDefaultsOperation *operation = [LGOUserDefaultsOperation new];
        operation.request = (LGOUserDefaultsRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.UserDefaults" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : nil;
    NSString *key = [dictionary[@"key"] isKindOfClass:[NSString class]] ? dictionary[@"key"] : nil;
    if (opt != nil && key != nil) {
        NSString *suite = [dictionary[@"suite"] isKindOfClass:[NSString class]] ? dictionary[@"suite"] : @"";
        return [self buildWithRequest:[[LGOUserDefaultsRequest alloc] initWithSuite:suite
                                                                                opt:opt
                                                                                key:key
                                                                              value:dictionary[@"value"]]];
    }
    return [LGORequestable rejectWithDomain:@"Native.UserDefaults" code:-2 reason:@"Opt && key require."];
}

@end
