//
//  LGOCanOpenURL.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCanOpenURL.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"

// Request
@interface LGOCanOpenURLRequest : LGORequest
@property (nonatomic, strong) NSString *URLString;
@end

@implementation LGOCanOpenURLRequest


@end

// Response
@interface LGOCanOpenURLResponse : LGOResponse
@property (nonatomic, assign) BOOL canOpen;
@end

@implementation LGOCanOpenURLResponse

- (NSDictionary *)toDictionary{
    return @{
             @"canOpen": [NSNumber numberWithBool:self.canOpen]
             };
}

@end

// Operation
@interface LGOCanOpenURLOperation : LGORequestable
@property (nonatomic, strong) LGOCanOpenURLRequest *request;
@end

@implementation LGOCanOpenURLOperation

- (LGOResponse *)requestSynchronize{
    LGOCanOpenURLResponse *response = [LGOCanOpenURLResponse new];
    NSURL *URL = [NSURL URLWithString:self.request.URLString];
    if (URL){
        response.canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
    }
    else {
        response.canOpen = NO;
    }
    return response;
}

@end

// Module
@implementation LGOCanOpenURL

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOCanOpenURLRequest class]]){
        LGOCanOpenURLOperation *operation = [LGOCanOpenURLOperation new];
        operation.request = (LGOCanOpenURLRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
     NSString *URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]] ? dictionary[@"URL"] : nil;
     if (URLString) {
         LGOCanOpenURLRequest *request = [LGOCanOpenURLRequest new];
         request.URLString = URLString;
         return [self buildWithRequest:request];
     }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: URL"];
}

@end

