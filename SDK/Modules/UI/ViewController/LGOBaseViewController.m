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
#import "LGOWebView.h"
#import "LGOProgressView.h"
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
            [[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] performSelector:@selector(attachSkeleton:URL:) withObject:self.webView withObject:self.url];
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
            if (self.preloadToken != nil && [[(WKWebView *)self.webView URL].scheme isEqualToString:@"file"] && ![(WKWebView *)self.webView isLoading]) {
                [(WKWebView *)self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.location.href = '%@'", self.url] completionHandler:nil];
                [self webView:(WKWebView *)self.webView didFinishNavigation:nil];
            }
            else {
                [(WKWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
            }
            if (self.title.length == 0) {
                self.title = [(WKWebView *)self.webView title];
            }
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
        UIProgressView __block *tempProgressView;
        if (_webView) {
            [_webView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIProgressView class]]) {
                    tempProgressView = obj;
                    *stop = YES;
                }
            }];
        }
        if (tempProgressView) {
            tempProgressView.hidden = !self.setting.showProgressView;
        }
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.webView scrollView].bounces = self.setting.allowBounce;
            [(WKWebView *)self.webView scrollView].alwaysBounceVertical = self.setting.alwaysBounce;
            [(WKWebView *)self.webView scrollView].showsVerticalScrollIndicator = self.setting.showsIndicator;
            [(WKWebView *)self.webView scrollView].showsHorizontalScrollIndicator = self.setting.showsIndicator;
            if (self.setting.backgroundColor != nil) {
                self.view.backgroundColor = self.setting.backgroundColor;
                [(WKWebView *)self.webView scrollView].backgroundColor = self.setting.backgroundColor;
            }
        }
        else if ([self.webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.webView scrollView].bounces = self.setting.allowBounce;
            [(UIWebView *)self.webView scrollView].alwaysBounceVertical = self.setting.alwaysBounce;
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
                if (self.navigationController.navigationBar.translucent) {
                    topLength += 20.0;
                }
            }
            if (!self.setting.navigationBarHidden) {
                if (self.navigationController.navigationBar.translucent) {
                    topLength += self.navigationController.navigationBar.bounds.size.height;
                    if ([self isiPhoneX]) {
                        topLength = 88;
                    }
                }
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

- (BOOL)isiPhoneX {
    if (@available(iOS 11.0, *)) {
        UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
        // 获取底部安全区域高度，iPhone X 竖屏下为 34.0，横屏下为 21.0，其他类型设备都为 0
        CGFloat bottomSafeInset = keyWindow.safeAreaInsets.bottom;
        if (bottomSafeInset == 34.0f || bottomSafeInset == 21.0f) {
            return YES;
        }
    }
    return NO;
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    _setting = [[LGOPageStore sharedStore] requestItem:url];
}

- (void)setSetting:(LGOPageRequest *)setting {
    _setting = setting;
    if (_setting && _setting.showProgressView) {
        LGOProgressView.customProgressViewClassName = nil;
    } else {
        LGOProgressView.customProgressViewClassName = @"UIView";
    }
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
            if (_webView == nil && self.preloadToken != nil && [[LGOCore modules] moduleWithName:@"WebView.Preload"] != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                _webView = [[[LGOCore modules] moduleWithName:@"WebView.Preload"] performSelector:@selector(fetchWebView:) withObject:self.preloadToken];
#pragma clang diagnostic pop
            }
            if (_webView == nil) {
                _webView = [LGOWKWebView requestWebViewFromPool];
            }
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
            if ([_webView isKindOfClass:[LGOWKWebView class]]) {
                if (LGOWKWebView.afterCreate) {
                    LGOWKWebView.afterCreate((LGOWKWebView *)_webView);
                }
            }
        } else {
            _webView = NSClassFromString(@"LGOWebView")
            ? [[NSClassFromString(@"LGOWebView") alloc] initWithFrame:self.view.bounds]
            : [[UIWebView alloc] initWithFrame:self.view.bounds];
            [(UIWebView *)_webView setLgo_args:self.args];
            if ([_webView isKindOfClass:[LGOWebView class]]) {
                if (LGOWebView.afterCreate) {
                    LGOWebView.afterCreate((LGOWebView *)_webView);
                }
            }
        }
    }
    return _webView;
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
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
            [[[LGOCore modules] moduleWithName:@"WebView.Skeleton"] performSelector:@selector(dismiss:) withObject:nil afterDelay:2.0];
        }
    }
#pragma clang diagnostic pop
}

+ (void)openURL:(NSURL *)URL navigationController:(UINavigationController *)navigationController animated:(BOOL)animated {
    if ([URL isKindOfClass:[NSURL class]] && [navigationController isKindOfClass:[UINavigationController class]]) {
        LGOBaseViewController *baseViewController = [[LGOBaseViewController alloc] init];
        baseViewController.url = URL;
        [navigationController pushViewController:baseViewController animated:animated];
    }
}
@end
