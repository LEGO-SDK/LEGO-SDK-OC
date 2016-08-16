//
//  LGORefresh.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "LGOBuildFailed.h"
#import "LGOCore.h"
#import "LGORefresh.h"
#import "LGOWKWebView+RefreshControl.h"
#import "LGOWebView+RefreshControl.h"

static int kRefreshOperationIdentifierKey;

@interface LGORefreshRequest : LGORequest

@property(nonatomic, strong) NSString *opt;  // add/complete

@end

@implementation LGORefreshRequest

@end

@interface LGORefreshOperation : LGORequestable

@property(nonatomic, strong) LGORefreshRequest *request;
@property(nonatomic, copy) LGORequestableAsynchronizeBlock responseBlock;

@end

@implementation LGORefreshOperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    self.responseBlock = callbackBlock;
    NSObject *sender = self.request.context.sender;
    if ([self.request.opt isEqualToString:@"add"]) {
        if ([sender isKindOfClass:[WKWebView class]]) {
            [((WKWebView *)sender) configureRefreshControl:self];
            objc_setAssociatedObject(sender, &kRefreshOperationIdentifierKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else if ([sender isKindOfClass:[UIWebView class]]) {
            [((UIWebView *)sender) configureRefreshControl:self];
            objc_setAssociatedObject(sender, &kRefreshOperationIdentifierKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else if ([self.request.opt isEqualToString:@"complete"]) {
        if ([sender isKindOfClass:[WKWebView class]]) {
            [((WKWebView *)sender)endRefreshing];
        } else if ([sender isKindOfClass:[UIWebView class]]) {
            [((UIWebView *)sender)endRefreshing];
        }
    }
}

- (void)handleRefreshControlTrigger {
    if (self.responseBlock) {
        self.responseBlock([LGOResponse new]);
    }
}
@end

@implementation LGORefresh

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGORefreshRequest class]]) {
        LGORefreshOperation *operation = [LGORefreshOperation new];
        operation.request = (LGORefreshRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"add";
    LGORefreshRequest *request = [LGORefreshRequest new];
    request.context = context;
    request.opt = opt;
    return [self buildWithRequest:request];
}

@end
