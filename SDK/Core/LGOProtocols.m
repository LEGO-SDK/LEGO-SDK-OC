//
//  LGOProtocols.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOProtocols.h"
@import WebKit;

@implementation LGORequestContext

- (UIViewController *)requestViewController {
    if (self.viewController != nil) {
        return self.viewController;
    }
    else {
        if (self.sender != nil && [self.sender isKindOfClass:[UIView class]]) {
            UIResponder *next = [(UIView *)self.sender nextResponder];
            while (next != nil && ![next isKindOfClass:[UIViewController class]]) {
                next = [next nextResponder];
            }
            if ([next isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)next;
            }
        }
        return nil;
    }
}

- (UIView *)requestWebView {
    if (self.sender != nil && ([self.sender isKindOfClass:[UIWebView class]] || [self.sender isKindOfClass:[WKWebView class]])) {
        return (UIView *)self.sender;
    }
    else {
        return nil;
    }
}

@end

@implementation LGORequest

@end

@implementation LGOResponse

- (NSDictionary *)toDictionary {
    return @{
             @"succeed": @(self.succeed)
             };
}

@end

@implementation LGORequestable

- (LGOResponse *)requestSynchronize {
    return [[LGOResponse alloc] init];
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    callbackBlock([self requestSynchronize]);
}

@end

@implementation LGOModule

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    return [[LGORequestable alloc] init];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    return [[LGORequestable alloc] init];
}

@end
