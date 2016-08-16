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
    } else {
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
    if (self.sender != nil &&
        ([self.sender isKindOfClass:[UIWebView class]] || [self.sender isKindOfClass:[WKWebView class]])) {
        return (UIView *)self.sender;
    } else {
        return nil;
    }
}

@end

@implementation LGORequest

- (instancetype)initWithContext:(LGORequestContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

@end

@implementation LGOResponse

- (instancetype)init {
    self = [super init];
    if (self) {
        _metaData = @{};
    }
    return self;
}

- (LGOResponse *)reject:(NSError *)error {
    _metaData = @{
        @"error" : @(YES),
        @"code" : @(error.code),
        @"reason" : error.localizedDescription != nil ? error.localizedDescription : @"",
    };
    return self;
}

- (LGOResponse *)accept:(NSDictionary *)metaData {
    if (metaData != nil) {
        _metaData = metaData;
    }
    return self;
}

- (NSDictionary *)resData {
    return @{};
}

@end

@interface LGORejecting : LGORequestable

@property (nonatomic, strong) NSError *error;

@end

@implementation LGORejecting

- (LGOResponse *)requestSynchronize {
    return [[[LGOResponse alloc] init] reject:self.error];
}

@end

@implementation LGORequestable

+ (LGORequestable *)rejectWithDomain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason {
    LGORejecting *rejecting = [[LGORejecting alloc] init];
    rejecting.error = [NSError errorWithDomain:(domain != nil ? domain : @"LEGO.SDK") code:code userInfo:@{NSLocalizedDescriptionKey: (reason != nil ? reason : @"")}];
    return rejecting;
}

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

- (NSDictionary *)synchronizeResponse:(UIView *)webView {
    return nil;
}

@end
