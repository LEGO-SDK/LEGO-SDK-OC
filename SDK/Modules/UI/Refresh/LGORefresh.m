//
//  LGORefresh.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGORefresh.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOWebView+RefreshControl.h"
#import "LGOWKWebView+RefreshControl.h"

@interface LGORefreshRequest : LGORequest

@property (nonatomic, strong) NSString *opt; // add/complete

@end

@implementation LGORefreshRequest

@end

@class LGORefreshOperation;

static LGORefreshOperation *currentOperation;

@interface LGORefreshOperation : LGORequestable

@property (nonatomic, strong) LGORefreshRequest *request;
@property (nonatomic, copy) LGORequestableAsynchronizeBlock responseBlock;

@end

@implementation LGORefreshOperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock{
    currentOperation = self;
    self.responseBlock = callbackBlock;
    NSObject *sender = self.request.context.sender;
    if ([self.request.opt isEqualToString:@"add"]){
        if ([sender isKindOfClass:[LGOWKWebView class]]){
            [((LGOWKWebView*)sender) configureRefreshControl:self];
        }
        else if ([sender isKindOfClass:[LGOWebView class]]){
            [((LGOWebView*)sender) configureRefreshControl:self];
        }
    }
    else if([self.request.opt isEqualToString:@"complete"]){
        if ([sender isKindOfClass:[LGOWKWebView class]]){
            [((LGOWKWebView*)sender) endRefreshing];
        }
        else if ([sender isKindOfClass:[LGOWebView class]]){
            [((LGOWebView*)sender) endRefreshing];
        }
    }
}

- (void)handleRefreshControlTrigger{
    if (self.responseBlock){
        self.responseBlock([LGOResponse new]);
    }
}
@end

@implementation LGORefresh

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGORefreshRequest class]]){
        LGORefreshOperation *operation = [LGORefreshOperation new];
        operation.request = (LGORefreshRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSString *opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"add";
    LGORefreshRequest *request = [LGORefreshRequest new];
    request.context = context;
    request.opt = opt;
    return [self buildWithRequest:request];
}

@end

