//
//  LGOWebViewController+Basic.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+Basic.h"

@implementation LGOWebViewController (Basic)

- (void)configureWebViewInitializeRequest {
    if (self.initializeRequest == nil) {
        return;
    }
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.webView loadRequest:self.initializeRequest];
    }
}

@end
