//
//  LGOWebViewController+Title.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+Title.h"
@import WebKit;

@implementation LGOWebViewController (Title)

@dynamic titleObserverConfigured;

- (void)configureTitleObserver {
    BOOL nilTitle = self.title == nil;
    BOOL nullTitle = self.title != nil && [self.title length] == 0;
    if (nilTitle || nullTitle) {
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
            self.titleObserverConfigured = YES;
        }
    }
}

- (void)unconfigureTitleObserver {
    if (self.titleObserverConfigured) {
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [self.webView removeObserver:self forKeyPath:@"title"];
        }
    }
}

- (void)title_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if ([change[@"new"] isKindOfClass:[NSString class]]) {
            self.title = change[@"new"];
        }
    }
}

- (void)title_webViewDidFinishLoad:(UIWebView *)webView {
    BOOL nilTitle = self.title == nil;
    BOOL nullTitle = self.title != nil && [self.title length] == 0;
    if (nilTitle || nullTitle) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

- (void)title_wkWebViewDidFinishLoad:(WKWebView *)webView {
    BOOL nilTitle = self.title == nil;
    BOOL nullTitle = self.title != nil && [self.title length] == 0;
    if (nilTitle || nullTitle) {
        self.title = webView.title;
    }
}

@end
