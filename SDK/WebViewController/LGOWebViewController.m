//
//  LGOWebViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController.h"
#import "LGOWebView.h"
#import "LGOWKWebView.h"
#import "LGOWebViewController+Basic.h"

@interface LGOWebViewController () <UIWebViewDelegate, WKNavigationDelegate>

@property (nonatomic, assign) BOOL titleObserverConfigured;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL progressObserverConfigured;

@end

@implementation LGOWebViewController

#pragma mark - Basic

- (void)dealloc
{
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        [(WKWebView *)self.webView setNavigationDelegate:nil];
    }
    else if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.webView setDelegate:nil];
    }
}

- (instancetype)initWithTitle:(NSString *)title URLString:(NSString *)URLString
{
    self = [super init];
    if (self) {
        self.title = title;
        NSURL *URL = [NSURL URLWithString:URLString];
        if (URL != nil) {
            self.initializeRequest = [NSURLRequest requestWithURL:URL];
            [self configureWebViewInitializeRequest];
        }
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.renderDidFinished = nil;
}

#pragma mark - Getter & Setter

- (UIView *)webView {
    if (_webView == nil) {
//        _webView = [[LGOWebView alloc] initWithFrame:CGRectZero];
//        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView = [[LGOWKWebView alloc] initWithFrame:CGRectZero];
        [(LGOWKWebView *)_webView setNavigationDelegate:self];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _webView;
}

- (void)setInitializeRequest:(NSURLRequest *)initializeRequest {
    _initializeRequest = initializeRequest;
    [self configureWebViewInitializeRequest];
}

@end




