//
//  LGOBounce.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "LGOBounce.h"
#import "LGOCore.h"

@interface LGOBounceRequest : LGORequest

@property(nonatomic, assign) BOOL allow;

@end

@implementation LGOBounceRequest

@end

@interface LGOBounceOperation : LGORequestable

@property(nonatomic, strong) LGOBounceRequest *request;

@end

@implementation LGOBounceOperation

- (LGOResponse *)requestSynchronize {
    UIView *webView = self.request.context.requestWebView;
    if ([webView isKindOfClass:[UIWebView class]]) {
        ((UIWebView *)webView).scrollView.bounces = self.request.allow;
        return [[LGOResponse new] accept:nil];
    } else if ([webView isKindOfClass:[WKWebView class]]) {
        ((WKWebView *)webView).scrollView.bounces = self.request.allow;
        return [[LGOResponse new] accept:nil];
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.Bounce"
                                                             code:-3
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"WebView not found."
                                                         }]];
    }
}

@end

@implementation LGOBounce

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOBounceRequest class]]) {
        LGOBounceOperation *operation = [LGOBounceOperation new];
        operation.request = (LGOBounceRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.Bounce" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSNumber *allow = dictionary[@"allow"];
    if (allow == nil) {
        return [LGORequestable rejectWithDomain:@"UI.Bounce" code:-2 reason:@"Allow required."];
    }
    LGOBounceRequest *request = [LGOBounceRequest new];
    request.context = context;
    request.allow = [allow isKindOfClass:[NSNumber class]] ? ((NSNumber *)allow).boolValue : NO;
    return [self buildWithRequest:request];
}

@end
