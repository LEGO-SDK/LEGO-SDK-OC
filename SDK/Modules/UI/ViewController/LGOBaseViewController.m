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
#import "LGOWKWebView.h"
#import <WebKit/WebKit.h>

@interface LGOBaseViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong) LGOPageRequest *setting;

@end

@implementation LGOBaseViewController

- (void)addHook:(LGOBaseViewControllerHookBlock)hookBlock forMethod:(NSString *)forMethod {
    NSMutableDictionary *hooks = [self.hooks mutableCopy] ?: [NSMutableDictionary dictionary];
    NSMutableArray *hookTarget = [hooks[forMethod] mutableCopy] ?: [NSMutableArray array];
    [hookTarget addObject:hookBlock];
    [hooks setObject:[hookTarget copy] forKey:forMethod];
    self.hooks = hooks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.webView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[LGOCore modules] moduleWithName:@"WebView.Skeleton"] != nil) {
        if ([[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] respondsToSelector:@selector(attachSkeleton:URL:)]) {
            [[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] performSelector:@selector(attachSkeleton:URL:) withObject:self.view withObject:self.url];
        }
    }
#pragma clang diagnostic pop
    [self loadSetting];
    [self loadRequest];
    for (LGOBaseViewControllerHookBlock hookBlock in self.hooks[@"viewDidLoad"]) {
        hookBlock();
    }
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
    for (LGOBaseViewControllerHookBlock hookBlock in self.hooks[@"loadRequest"]) {
        hookBlock();
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
    if (newSetting == nil && [[LGOPageStore sharedStore] requestItem:self.url] == nil) {
        return;
    }
    if (newSetting == nil && (self.setting.urlPattern == nil || self.setting.urlPattern.length == 0)) {
        return;
    }
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
        CGFloat topLength = self.topLayoutGuide.length;
        CGFloat bottomLength = self.bottomLayoutGuide.length;
        self.webView.frame = CGRectMake(0.0,
                                        topLength,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height - topLength - bottomLength);
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
    for (LGOBaseViewControllerHookBlock hookBlock in self.hooks[@"viewWillAppear"]) {
        hookBlock();
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    for (LGOBaseViewControllerHookBlock hookBlock in self.hooks[@"viewDidAppear"]) {
        hookBlock();
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.setting) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    for (LGOBaseViewControllerHookBlock hookBlock in self.hooks[@"viewWillDisappear"]) {
        hookBlock();
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    for (LGOBaseViewControllerHookBlock hookBlock in self.hooks[@"viewDidDisappear"]) {
        hookBlock();
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.setting.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.setting == nil && [self.navigationController isKindOfClass:[LGOBaseNavigationController class]]) {
        return [(LGOBaseNavigationController *)self.navigationController defaultStatusBarStyle];
    }
    return self.setting.statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIView *)webView {
    if (_webView == nil) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            _webView = [LGOWKWebView requestWebViewFromPool];
            if (_webView == nil) {
                _webView = NSClassFromString(@"LGOWKWebView")
                ? [[NSClassFromString(@"LGOWKWebView") alloc] initWithFrame:self.view.bounds]
                : [[WKWebView alloc] initWithFrame:self.view.bounds];
            }
            [(WKWebView *)_webView setLgo_args:self.args];
            [(WKWebView *)_webView setNavigationDelegate:self];
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

#pragma mark - WKNavigationDelegate

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[LGOCore modules] moduleWithName:@"WebView.Skeleton"] != nil) {
        if ([[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] respondsToSelector:@selector(dismiss:)]) {
            [[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] performSelector:@selector(dismiss:) withObject:nil];
        }
    }
#pragma clang diagnostic pop
}

@end
