//
//  LGOViewController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOPage.h"

@class WKWebView, WKNavigation;

typedef void(^LGOBaseViewControllerHookBlock)();

@interface LGOBaseViewController : UIViewController

@property (nonatomic, copy) NSString *preloadToken;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, readonly) LGOPageRequest *setting;
@property (nonatomic, readonly) UIView *webView;
@property (nonatomic, copy) NSDictionary<NSString *, NSArray<LGOBaseViewControllerHookBlock> *> *hooks;

+ (void)openURL:(NSURL *)URL navigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

- (void)reloadSetting:(LGOPageRequest *)newSetting;

- (void)addHook:(LGOBaseViewControllerHookBlock)hookBlock forMethod:(NSString *)forMethod;

#pragma mark - WKNavigationDelegate

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView;

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

@end
