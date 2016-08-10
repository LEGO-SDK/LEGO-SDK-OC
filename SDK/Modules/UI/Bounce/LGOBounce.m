//
//  LGOBounce.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBounce.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOWebView.h"
#import "LGOWKWebView.h"

@interface LGOBounceRequest : LGORequest

@property (nonatomic, assign) BOOL allow;

@end

@implementation LGOBounceRequest

@end

@interface LGOBounceOperation : LGORequestable

@property (nonatomic, strong) LGOBounceRequest *request;

@end

@implementation LGOBounceOperation

- (LGOResponse *)requestSynchronize{
    UIView *webView = self.request.context.requestWebView;
    if ([webView isKindOfClass:[LGOWebView class]]){
        ((LGOWebView *)webView).scrollView.bounces = self.request.allow;
    }
    else if ([webView isKindOfClass:[LGOWKWebView class]]){
        ((LGOWKWebView *)webView).scrollView.bounces = self.request.allow;
    }
    return [LGOResponse new];
}

@end

@implementation LGOBounce

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOBounceRequest class]]){
        LGOBounceOperation *operation = [LGOBounceOperation new];
        operation.request = (LGOBounceRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSNumber *allow = dictionary[@"allow"];
    if (allow == nil){
        return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: allow"];
    }
    
    LGOBounceRequest *request = [LGOBounceRequest new];
    request.context = context;
    request.allow = [allow isKindOfClass:[NSNumber class]] ? ((NSNumber *)allow).boolValue : NO;
    return [self buildWithRequest:request];
}

@end

