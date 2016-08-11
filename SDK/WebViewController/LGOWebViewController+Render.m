//
//  LGOWebViewController+Render.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+Render.h"
#import "LGOWebViewController+Title.h"
#import <WebKit/WebKit.h>


// #available iOS8+
@implementation LGOWebViewController (Render)

- (void)render_webViewDidFinishLoad:(UIWebView*)webView{
    if (self.renderDidFinished){
        self.renderDidFinished();
    }
}

- (void)startPrerending{
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow){
        self.isPrerending = YES;
        [keyWindow addSubview:self.webView];
        self.webView.alpha = 0.0;
        self.webView.frame = [UIScreen mainScreen].bounds;
    }
}

- (void)stopPrerending{
    self.isPrerending = YES;
    self.webView.alpha = 1.0;
    if ( self.webView.superview != self.view ){
        [self.webView removeFromSuperview];
        [self.view addSubview:self.webView];
        self.webView.frame = [UIScreen mainScreen].bounds;
        [self.view layoutIfNeeded];
        [self.webView layoutIfNeeded];
    }
}

- (void)webViewDidFinishedRender:(WKWebView*)webView{
    if (self.renderDidFinished) {
        [self stopPrerending];
        [self title_wkWebViewDidFinishLoad:webView];
        self.renderDidFinished();
        WKWebView* webView = [self.webView isKindOfClass:[WKWebView class]]? (WKWebView*)self.webView : nil;
        if(webView){
            [webView evaluateJavaScript:@"JSRender()" completionHandler:nil];
        }
    }
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation{
    [self title_wkWebViewDidFinishLoad:webView];
}

@end
