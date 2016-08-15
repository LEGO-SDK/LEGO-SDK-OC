//
//  LGOModalController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "LGOModalController.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "UIViewController+LGOViewController.h"

@interface LGOModalRequest: LGORequest

@property (nonatomic, copy) NSString *opt; // present/dismiss
@property (nonatomic, copy) NSString *path; // an URLString or LGOViewControllerMapping[path]
@property (nonatomic, assign) BOOL animated; // push or pop need animation. Defaults to true.
@property (nonatomic, copy) NSString *title; // next title.
@property (nonatomic, assign) BOOL statusBarHidden; // next title.
@property (nonatomic, assign) BOOL navigationBarHidden; // next title.
@property (nonatomic, strong) NSDictionary *args; // deliver args to next ViewController

@end

@implementation LGOModalRequest

@end

@class LGOModalOperation;

LGOModalOperation *lastOperation;

NSDate *lastPresent;

@interface LGOModalOperation: LGORequestable

@property (nonatomic, strong) LGOModalRequest *request;

@end

@implementation LGOModalOperation

- (LGOResponse *)requestSynchronize{
    if ([self.request.opt isEqualToString:@"present"]){
        [self present];
    }
    else if ([self.request.opt isEqualToString:@"dismiss"]){
        [self dismiss];
    }
    return [LGOResponse new];
}

- (void)dismiss{
    UIViewController *viewController = [self requestViewController];
    if(viewController == nil){ return; }
    
    UIViewController *presentedViewController = viewController.presentedViewController;
    if (presentedViewController != nil) {
        [presentedViewController dismissViewControllerAnimated:self.request.animated completion:nil];
        return;
    }
    
    UINavigationController *naviViewController = viewController.navigationController;
    if (naviViewController != nil){
        [naviViewController dismissViewControllerAnimated:self.request.animated completion:nil];
        return;
    }
    
    if (viewController.presentingViewController != nil){
        [viewController dismissViewControllerAnimated:self.request.animated completion:nil];
    }
    
}

- (void)present{
    if (lastPresent != nil && [lastPresent timeIntervalSinceNow] > -1.0 ){
        NSLog(@"两次 Present 的操作不能少于 1 秒");
        return;
    }
    else {
        lastPresent = [NSDate new];
    }
    
    NSURL *relativeURL = nil;
    UIView *webView = self.request.context.requestWebView;
    if (webView != nil && [webView isKindOfClass:[UIWebView class]]){
        relativeURL = ((UIWebView *)webView).request.URL;
    }
    if (webView != nil && [webView isKindOfClass:[WKWebView class]]){
        relativeURL = ((WKWebView *)webView).URL;
    }
    NSURL *URL = [NSURL URLWithString:self.request.path relativeToURL:relativeURL];
    if (URL != nil){
        [self presentWebView:URL];
    }
}

- (void)presentWebView:(NSURL *)URL{
    UIViewController *viewController = [self requestViewController];
    if (viewController == nil) {
        return;
    }
    UIViewController *nextViewController = [UIViewController new];
    [nextViewController lgo_openWebViewWithRequest:[[NSURLRequest alloc] initWithURL:URL] args:self.request.args];
    nextViewController.hidesBottomBarWhenPushed = YES;
    nextViewController.title = self.request.title;
    if ([nextViewController respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")]) {
        [nextViewController setValue:@(self.request.navigationBarHidden) forKey:@"lgo_navigationBarHidden"];
    }
    if ([nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarHidden")]) {
        [nextViewController setValue:@(self.request.statusBarHidden) forKey:@"lgo_statusBarHidden"];
    }
    UIViewController *presentingViewController = nextViewController;
    UINavigationController *navigationController = [self requestNavigationController:nextViewController];
    if (navigationController != nil){
        presentingViewController = navigationController;
    }
    else {
        presentingViewController = nextViewController;
    }
    [viewController presentViewController:presentingViewController animated:YES completion:nil];
}

- (UINavigationController *)requestNavigationController:(UIViewController*)rootViewController{
    UIViewController *requestVC = [self requestViewController];
    if (requestVC != nil && requestVC.navigationController != nil){
        Class naviClz = [requestVC.navigationController class];
        UINavigationController *naviController = [[naviClz alloc] init];
        [naviController setViewControllers:@[rootViewController] animated:NO];
        rootViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:naviController action: @selector(lgo_dismiss)];
        return naviController;
    }
    return nil;
}

- (UIViewController *)requestViewController{
    UIView *view = [self.request.context.sender isKindOfClass:[UIView class]] ? (UIView *)self.request.context.sender:nil;
    if(view){
        UIResponder *next = [view nextResponder];
        for (int count = 0; count<100; count++) {
            if([next isKindOfClass:[UIViewController class]]){
                return (UIViewController *)next;
            }
            else{
                if (next != nil){
                    next = [next nextResponder];
                }
            }
        }
    }
    return nil;
}

@end

@implementation LGOModalController

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOModalRequest class]]){
        LGOModalOperation *operation = [LGOModalOperation new];
        operation.request = (LGOModalRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    LGOModalRequest *request = [LGOModalRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"present";
    request.path = [dictionary[@"path"] isKindOfClass:[NSString class]] ? dictionary[@"path"] : @"";
    request.animated = [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"animated"]).boolValue : YES;
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : @"";
    request.statusBarHidden = [dictionary[@"statusBarHidden"] isKindOfClass:[NSNumber class]] ? [dictionary[@"statusBarHidden"] boolValue] : NO;
    request.navigationBarHidden = [dictionary[@"navigationBarHidden"] isKindOfClass:[NSNumber class]] ? [dictionary[@"navigationBarHidden"] boolValue] : NO;
    request.args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    return [self buildWithRequest:request];
}

@end
