//
//  LGOViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOBaseViewController.h"
#import "LGOPageStore.h"
#import "UIWebView+LGOViewControllerArgs.h"
#import "WKWebView+LGOViewControllerArgs.h"
#import "LGOJavaScriptUserContentController.h"
#import <WebKit/WebKit.h>

@interface LGOBaseViewController ()

@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong) LGOPageRequest *setting;

@end

@implementation LGOBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self loadSetting];
    [self loadRequest];
}

- (void)loadRequest {
    if (self.url != nil) {
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        }
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        }
    }
}

- (void)loadSetting {
    if (self.setting) {
        self.automaticallyAdjustsScrollViewInsets = !self.setting.fullScreenContent;
        self.title = self.setting.title;
        [self setNeedsStatusBarAppearanceUpdate];
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.webView scrollView].bounces = self.setting.allowBounce;
            [(WKWebView *)self.webView scrollView].showsVerticalScrollIndicator = self.setting.showsIndicator;
            [(WKWebView *)self.webView scrollView].showsHorizontalScrollIndicator = self.setting.showsIndicator;
        }
        else if ([self.webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.webView scrollView].bounces = self.setting.allowBounce;
            [(UIWebView *)self.webView scrollView].showsVerticalScrollIndicator = self.setting.showsIndicator;
            [(UIWebView *)self.webView scrollView].showsHorizontalScrollIndicator = self.setting.showsIndicator;
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    _setting = [[LGOPageStore sharedStore] requestItem:url];
}

- (BOOL)prefersStatusBarHidden {
    return self.setting.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.setting.statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIView *)webView {
    if (_webView == nil) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            _webView = NSClassFromString(@"LGOWKWebView")
            ? [[NSClassFromString(@"LGOWKWebView") alloc] initWithFrame:self.view.bounds]
            : [[WKWebView alloc] initWithFrame:self.view.bounds];
            [(WKWebView *)_webView setLgo_args:self.args];
            if ([[[(WKWebView *)_webView configuration] userContentController]
                 isKindOfClass:[LGOJavaScriptUserContentController class]]) {
                [(LGOJavaScriptUserContentController *)[[(WKWebView *)_webView configuration]
                                                        userContentController] addPrescripts];
            }
        } else {
            _webView = NSClassFromString(@"LGOWebView")
            ? [[NSClassFromString(@"LGOWebView") alloc] initWithFrame:self.view.bounds]
            : [[UIWebView alloc] initWithFrame:self.view.bounds];
            [(UIWebView *)_webView setLgo_args:self.args];
        }
    }
    return _webView;
}

@end
