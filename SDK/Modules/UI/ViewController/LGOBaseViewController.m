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
#import "LGOBaseNavigationController.h"
#import <WebKit/WebKit.h>

@interface LGOBaseViewController ()

@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong) LGOPageRequest *setting;

@end

@implementation LGOBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
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
    if (self.setting != nil) {
        self.title = self.setting.title;
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.webView scrollView].bounces = self.setting.allowBounce;
            [(WKWebView *)self.webView scrollView].showsVerticalScrollIndicator = self.setting.showsIndicator;
            [(WKWebView *)self.webView scrollView].showsHorizontalScrollIndicator = self.setting.showsIndicator;
            if (self.setting.backgroundColor != nil) {
                self.view.backgroundColor = self.setting.backgroundColor;
                [(WKWebView *)self.webView scrollView].backgroundColor = self.setting.backgroundColor;
            }
        }
        else if ([self.webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.webView scrollView].bounces = self.setting.allowBounce;
            [(UIWebView *)self.webView scrollView].showsVerticalScrollIndicator = self.setting.showsIndicator;
            [(UIWebView *)self.webView scrollView].showsHorizontalScrollIndicator = self.setting.showsIndicator;
            if (self.setting.backgroundColor != nil) {
                self.view.backgroundColor = self.setting.backgroundColor;
                [(UIWebView *)self.webView scrollView].backgroundColor = self.setting.backgroundColor;
            }
        }
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)reloadSetting:(LGOPageRequest *)newSetting {
    self.setting = newSetting == nil ? [[LGOPageStore sharedStore] requestItem:self.url] : newSetting;
    [self loadSetting];
    if ([self.navigationController isKindOfClass:[LGOBaseNavigationController class]]) {
        [(LGOBaseNavigationController *)self.navigationController reloadSetting];
    }
    [self resetLayout];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self resetLayout];
}

- (void)resetLayout {
    if (self.setting != nil) {
        if (self.setting.fullScreenContent) {
            self.webView.frame = self.view.bounds;
        }
        else {
            CGFloat topLength = 0.0;
            if (!self.setting.statusBarHidden) {
                topLength += 20.0;
            }
            if (!self.setting.navigationBarHidden) {
                topLength += self.navigationController.navigationBar.bounds.size.height;
            }
            CGFloat bottomLength = self.hidesBottomBarWhenPushed ? 0.0 : self.tabBarController.tabBar.bounds.size.height;
            self.webView.frame = CGRectMake(0.0,
                                            topLength,
                                            self.view.bounds.size.width,
                                            self.view.bounds.size.height - topLength - bottomLength);
        }
    }
    else {
        self.webView.frame = self.view.bounds;
    }
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    _setting = [[LGOPageStore sharedStore] requestItem:url];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.setting) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.setting.statusBarStyle animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:self.setting.statusBarHidden withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.setting) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
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
