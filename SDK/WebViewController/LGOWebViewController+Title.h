//
//  LGOWebViewController+Title.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController.h"

@class WKWebView;

@interface LGOWebViewController (Title)

@property (nonatomic, assign) BOOL titleObserverConfigured;

- (void)configureTitleObserver;

- (void)unconfigureTitleObserver;

- (void)title_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context;

- (void)title_webViewDidFinishLoad:(UIWebView *)webView;

- (void)title_wkWebViewDidFinishLoad:(WKWebView *)webView;

@end
