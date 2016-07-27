//
//  LGOWebViewController+RefreshControl.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+RefreshControl.h"
@import WebKit;

@implementation LGOWebViewController (RefreshControl)

@dynamic refreshControl;

- (void)requestRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
}

- (void)configureRefreshControl {
    [self requestRefreshControl];
    if (self.refreshControl != nil) {
        [self.refreshControl addTarget:self action:@selector(handleRefreshControlTrigger) forControlEvents:UIControlEventValueChanged];
    }
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        [[(WKWebView *)self.webView scrollView] addSubview:self.refreshControl];
    }
    else if ([self.webView isKindOfClass:[UIWebView class]]) {
        [[(UIWebView *)self.webView scrollView] addSubview:self.refreshControl];
    }
}

- (void)handleRefreshControlTrigger {
    
}

@end
