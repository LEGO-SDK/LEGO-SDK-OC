//
//  LGOCanOpenURL.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCanOpenURL.h"
#import "LGOCore.h"

@interface LGOCanOpenURLRequest : LGORequest

@property(nonatomic, strong) NSString *URLString;

@end

@implementation LGOCanOpenURLRequest

@end

@interface LGOCanOpenURLResponse : LGOResponse

@end

@implementation LGOCanOpenURLResponse

@end

@interface LGOCanOpenURLOperation : LGORequestable

@property(nonatomic, strong) LGOCanOpenURLRequest *request;

@end

@implementation LGOCanOpenURLOperation

- (LGOResponse *)requestSynchronize {
    LGOCanOpenURLResponse *response = [LGOCanOpenURLResponse new];
    NSURL *URL = [NSURL URLWithString:self.request.URLString];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        return [response accept:nil];
    }
    else {
        return [response reject:[NSError errorWithDomain:@"Native.CanOpenURL" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Can not openURL."}]];
    }
}

@end

@implementation LGOCanOpenURL

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.CanOpenURL" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOCanOpenURLRequest class]]) {
        LGOCanOpenURLOperation *operation = [LGOCanOpenURLOperation new];
        operation.request = (LGOCanOpenURLRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.CanOpenURL" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]] ? dictionary[@"URL"] : nil;
    if (URLString != nil) {
        LGOCanOpenURLRequest *request = [LGOCanOpenURLRequest new];
        request.URLString = URLString;
        return [self buildWithRequest:request];
    }
    return [LGORequestable rejectWithDomain:@"Native.CanOpenURL" code:-2 reason:@"URL require."];
}

@end
