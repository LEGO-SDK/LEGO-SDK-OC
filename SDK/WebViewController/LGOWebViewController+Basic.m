//
//  LGOWebViewController+Basic.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+Basic.h"
#import "LGOCore.h"
#import "LGOWebCache.h"
#import "LGOWebService.h"
#import "LGOWebHTTPService.h"
@import WebKit;

@implementation LGOWebViewController (Basic)

- (void)configureWebViewInitializeRequest {
    if (self.initializeRequest == nil) {
        return;
    }
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.webView loadRequest:self.initializeRequest];
    }
    else if ([self.webView isKindOfClass:[WKWebView class]]) {
        if ([self.initializeRequest.URL.host isEqualToString:@"localhost"]) {
        }
        else if ([[[LGOCore webCache] webService] cachedForRequest:self.initializeRequest]) {
            self.initializeRequest = [LGOWebHTTPService proxyRequest:self.initializeRequest];
        }
        [(WKWebView *)self.webView loadRequest:self.initializeRequest];
    }
}

@end
