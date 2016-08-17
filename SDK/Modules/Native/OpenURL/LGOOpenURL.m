//
//  LGOOpenURL.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOOpenURL.h"

@interface LGOOpenURLRequest : LGORequest

@property(nonatomic, strong) NSString *URLString;

@end

@implementation LGOOpenURLRequest

@end

@interface LGOOpenURLOperation : LGORequestable

@property(nonatomic, strong) LGOOpenURLRequest *request;

@end

@implementation LGOOpenURLOperation

- (LGOResponse *)requestSynchronize {
    LGOResponse *response = [LGOResponse new];
    NSURL *URL = [NSURL URLWithString:self.request.URLString];
    if (URL != nil) {
        if ([[UIApplication sharedApplication] openURL:URL]) {
            return [response accept:nil];
        }
        return [response reject:[NSError errorWithDomain:@"Native.OpenURL"
                                                    code:-3
                                                userInfo:@{
                                                    NSLocalizedDescriptionKey : @"Open failed."
                                                }]];
    } else {
        return [response reject:[NSError errorWithDomain:@"Native.OpenURL"
                                                    code:-4
                                                userInfo:@{
                                                    NSLocalizedDescriptionKey : @"Invalid url value."
                                                }]];
    }
}

@end

@implementation LGOOpenURL

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOOpenURLRequest class]]) {
        LGOOpenURLOperation *operation = [LGOOpenURLOperation new];
        operation.request = (LGOOpenURLRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.OpenURL" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]] ? dictionary[@"URL"] : nil;
    if (URLString != nil) {
        LGOOpenURLRequest *request = [LGOOpenURLRequest new];
        request.URLString = URLString;
        return [self buildWithRequest:request];
    }
    return [LGORequestable rejectWithDomain:@"Native.OpenURL" code:-2 reason:@"URL require."];
}

@end
