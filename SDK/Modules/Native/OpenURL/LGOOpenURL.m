//
//  LGOOpenURL.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOOpenURL.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"

// Request
@interface LGOOpenURLRequest : LGORequest
@property (nonatomic, strong) NSString *URLString;
@end

@implementation LGOOpenURLRequest

@end



// Response
@interface LGOOpenURLResponse : LGOResponse
@property (nonatomic, assign) BOOL finished;
@end

@implementation LGOOpenURLResponse

- (NSDictionary *)toDictionary{
    return @{
             @"finished": [NSNumber numberWithBool:self.finished]
             };
}

@end



// Operation
@interface LGOOpenURLOperation : LGORequestable

@property (nonatomic, strong) LGOOpenURLRequest *request;

@end

@implementation LGOOpenURLOperation

- (LGOResponse *)requestSynchronize{
    LGOOpenURLResponse *response = [LGOOpenURLResponse new];
    NSURL *URL = [NSURL URLWithString:self.request.URLString];
    if (URL){
        response.finished = [[UIApplication sharedApplication] openURL:URL];
    }
    else{
        response.finished = NO;
    }
    return response;
}

@end



// Module
@implementation LGOOpenURL

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOOpenURLRequest class]]){
        LGOOpenURLOperation *operation = [LGOOpenURLOperation new];
        operation.request = (LGOOpenURLRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSString *URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]] ? dictionary[@"URL"] : nil;
    if (URLString) {
        LGOOpenURLRequest *request = [LGOOpenURLRequest new];
        request.URLString = URLString;
        return [self buildWithRequest:request];
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: URL"];
}

@end



