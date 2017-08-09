//
//  LGOPreload.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/8/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOPreload.h"
#import "LGOWKWebView.h"

@interface LGOPreload ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, LGOWKWebView *> *pool;

@end

@interface LGOPreloadRequest : LGORequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *url;

@end

@implementation LGOPreloadRequest

@end

@interface LGOPreloadOperation : LGORequestable

@property (nonatomic, strong) LGOPreloadRequest *request;

@end

@implementation LGOPreloadOperation

- (LGOResponse *)requestSynchronize {
    if (self.request.token == nil || self.request.url == nil) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"WebView.Preload" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"token, url required."}]];
    }
    LGOWKWebView *webView = [[LGOWKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.request.url]]];
    [[(LGOPreload *)[[LGOCore modules] moduleWithName:@"WebView.Preload"] pool] setObject:webView forKey:self.request.token];
    return [[LGOResponse new] accept:nil];
}

@end

@implementation LGOPreload

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pool = [NSMutableDictionary dictionary];
    }
    return self;
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    if (self.pool.count >= 3) {
        return [LGORequestable rejectWithDomain:@"WebView.Preload"
                                           code:-2
                                         reason:@"Too much preload webview. max limit 3."];
    }
    LGOPreloadRequest *request = [LGOPreloadRequest new];
    request.token = [dictionary[@"token"] isKindOfClass:[NSString class]] ? dictionary[@"token"] : nil;
    request.url = [dictionary[@"url"] isKindOfClass:[NSString class]] ? dictionary[@"url"] : nil;
    LGOPreloadOperation *operation = [LGOPreloadOperation new];
    operation.request = request;
    return operation;
}

- (LGOWKWebView *)fetchWebView:(NSString *)token {
    if (self.pool[token] != nil) {
        LGOWKWebView *oldWebView = self.pool[token];
        LGOWKWebView *newWebView = [[LGOWKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [newWebView loadRequest:[NSURLRequest requestWithURL:oldWebView.URL]];
        [self.pool setObject:newWebView forKey:token];
        return oldWebView;
    }
    return nil;
}

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"WebView.Preload" instance:[self new]];
}

@end
