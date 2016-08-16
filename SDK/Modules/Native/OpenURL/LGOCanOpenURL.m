//
//  LGOCanOpenURL.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGOCanOpenURL.h"
#import "LGOCore.h"

@interface LGOCanOpenURLRequest : LGORequest

@property(nonatomic, strong) NSString *URLString;

@end

@implementation LGOCanOpenURLRequest

@end

@interface LGOCanOpenURLResponse : LGOResponse

@property(nonatomic, assign) BOOL canOpen;

@end

@implementation LGOCanOpenURLResponse

- (NSDictionary *)toDictionary {
    return @{ @"canOpen" : [NSNumber numberWithBool:self.canOpen] };
}

@end

@interface LGOCanOpenURLOperation : LGORequestable

@property(nonatomic, strong) LGOCanOpenURLRequest *request;

@end

@implementation LGOCanOpenURLOperation

- (LGOResponse *)requestSynchronize {
    LGOCanOpenURLResponse *response = [LGOCanOpenURLResponse new];
    NSURL *URL = [NSURL URLWithString:self.request.URLString];
    if (URL != nil) {
        response.canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
    } else {
        response.canOpen = NO;
    }
    return response;
}

@end

@implementation LGOCanOpenURL

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOCanOpenURLRequest class]]) {
        LGOCanOpenURLOperation *operation = [LGOCanOpenURLOperation new];
        operation.request = (LGOCanOpenURLRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]] ? dictionary[@"URL"] : nil;
    if (URLString != nil) {
        LGOCanOpenURLRequest *request = [LGOCanOpenURLRequest new];
        request.URLString = URLString;
        return [self buildWithRequest:request];
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: URL"];
}

@end
