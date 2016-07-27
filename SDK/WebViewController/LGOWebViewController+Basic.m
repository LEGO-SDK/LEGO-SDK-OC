//
//  LGOWebViewController+Basic.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+Basic.h"
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
        [(WKWebView *)self.webView loadRequest:self.initializeRequest];
    }
}

@end
