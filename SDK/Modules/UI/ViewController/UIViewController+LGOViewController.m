//
//  UIViewController+LGOViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "UIViewController+LGOViewController.h"
#import "UIWebView+LGOViewControllerArgs.h"
#import "WKWebView+LGOViewControllerArgs.h"
#import "LGOJavaScriptUserContentController.h"

@implementation UIViewController (LGOViewController)

- (void)lgo_openWebViewWithRequest:(NSURLRequest *)request args:(NSDictionary *)args {
    if (self.lgo_webView == nil) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            self.lgo_webView = NSClassFromString(@"LGOWKWebView") ? [[NSClassFromString(@"LGOWKWebView") alloc] initWithFrame:self.view.bounds] : [[WKWebView alloc] initWithFrame:self.view.bounds];
            [(WKWebView *)self.lgo_webView setLgo_args:args];
            if ([[[(WKWebView *)self.lgo_webView configuration] userContentController] isKindOfClass:[LGOJavaScriptUserContentController class]]) {
                [(LGOJavaScriptUserContentController *)[[(WKWebView *)self.lgo_webView configuration] userContentController] addPrescripts];
            }
            [(WKWebView *)self.lgo_webView loadRequest:request];
        }
        else {
            self.lgo_webView = NSClassFromString(@"LGOWebView") ? [[NSClassFromString(@"LGOWebView") alloc] initWithFrame:self.view.bounds] : [[UIWebView alloc] initWithFrame:self.view.bounds];
            [(UIWebView *)self.lgo_webView setLgo_args:args];
            [(UIWebView *)self.lgo_webView loadRequest:request];
        }
    }
    self.lgo_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.lgo_webView];
    [self lgo_loadRequest:request];
}

- (void)lgo_loadRequest:(NSURLRequest *)request {
    if ([self.lgo_webView isKindOfClass:[WKWebView class]]) {
        [(WKWebView *)self.lgo_webView loadRequest:request];
    }
    if ([self.lgo_webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.lgo_webView loadRequest:request];
    }
}

- (void)lgo_dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

static int kWebViewIdentifierKey;

- (UIView *)lgo_webView {
    return objc_getAssociatedObject(self, &kWebViewIdentifierKey);
}

- (void)setLgo_webView:(UIView *)lgo_webView {
    objc_setAssociatedObject(self, &kWebViewIdentifierKey, lgo_webView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
