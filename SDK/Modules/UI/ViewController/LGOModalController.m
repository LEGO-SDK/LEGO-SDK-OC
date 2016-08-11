//
//  LGOModalController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "LGOModalController.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOModalPresentationTransition.h"
#import "LGOModalDismissTransition.h"
#import "LGOWebViewController.h"
#import "LGOWKWebView.h"

@interface LGOModalRequest: LGORequest

@property (nonatomic, strong) NSString *opt; // present/dismiss
@property (nonatomic, strong) NSString *path; // an URLString or LGOViewControllerMapping[path]
@property (nonatomic, assign) BOOL animated; // push or pop need animation. Defaults to true.
@property (nonatomic, assign) BOOL withNavigationController; // ViewController will wrap by navigationController, defaults to YES.
@property (nonatomic, assign) UIEdgeInsets edgeInsets; // ViewController will wrap by UIWindow with EdgeInsets.
@property (nonatomic, assign) BOOL edgeInsetsDidSet;
@property (nonatomic, strong) NSDictionary<NSString *, id> *args; // deliver args to next ViewController

@end

@implementation LGOModalRequest

@end

@class LGOModalOperation;

LGOModalOperation *lastOperation;

NSDate *lastPresent;

@interface LGOModalOperation: LGORequestable<UIViewControllerTransitioningDelegate>

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
    UIViewController *webViewController = self.request.context.requestViewController;
    if (webViewController != nil && [webViewController isKindOfClass:[LGOWebViewController class]]){
        UIView *webView = ((LGOWebViewController *)webViewController).webView;
        if (webView != nil && [webView isKindOfClass:[LGOWKWebView class]]){
            relativeURL = ((LGOWKWebView*)webView).URL;
        }
    }
    
    NSURL *URL = [NSURL URLWithString:self.request.path relativeToURL:relativeURL];
    if (URL != nil){
        [self presentWebView:URL];
    }
}

- (void)presentWebView:(NSURL *)URL{
    UIViewController *viewController = [self requestViewController];
    if (viewController == nil) {return;}
    LGOWebViewController *aWebViewController = [LGOWebViewController new];
    aWebViewController.initializeContext = self.request.args;
    aWebViewController.initializeRequest = [[NSURLRequest alloc] initWithURL:URL];
    aWebViewController.title = [self.request.args[@"title"] isKindOfClass:[NSString class]]? self.request.args[@"title"] : @"";
    
    static BOOL presented = NO;
    UIViewController *presentingViewController = aWebViewController;
    if (self.request.withNavigationController){
        UINavigationController *naviController = [self requestNavigationController:aWebViewController];
        if (naviController != nil){
            if (self.request.edgeInsetsDidSet){
                naviController.modalPresentationStyle = UIModalPresentationCustom;
                naviController.transitioningDelegate = self;
                lastOperation = self;
            }
            presentingViewController = naviController;
        }
        else {
            if (self.request.edgeInsetsDidSet){
                aWebViewController.modalPresentationStyle = UIModalPresentationCustom;
                aWebViewController.transitioningDelegate = self;
                lastOperation = self;
            }
            presentingViewController = aWebViewController;
        }
    }
    else{
        if (self.request.edgeInsetsDidSet){
            aWebViewController.modalPresentationStyle = UIModalPresentationCustom;
            aWebViewController.transitioningDelegate = self;
            lastOperation = self;
        }
        presentingViewController = aWebViewController;
    }
    
    if (aWebViewController.isPrerending){
        aWebViewController.renderDidFinished = ^{
            if (presented){ return ; }
            presented = YES;
            [viewController presentViewController:presentingViewController animated:YES completion:nil];
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (presented){ return ; }
            presented = YES;
            [viewController presentViewController:presentingViewController animated:YES completion:nil];
        });
    }
    else{
        [viewController presentViewController:presentingViewController animated:YES completion:nil];
    }
}

- (UINavigationController *)requestNavigationController:(UIViewController*)rootViewController{
    UIViewController* requestVC = [self requestViewController];
    if (requestVC != nil && requestVC.navigationController != nil){
        Class naviClz = [requestVC.navigationController class];
        UINavigationController *naviController = [[naviClz alloc] init];
        [naviController setViewControllers:@[rootViewController] animated:NO];
//        rootViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:naviController action: @selector(lgo_dismiss)];
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

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    if (self.request.edgeInsetsDidSet){
        return [[LGOModalPresentationTransition alloc] initWithTargetEdgeInsets:self.request.edgeInsets];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    if (self.request.edgeInsetsDidSet){
        return [[LGOModalDismissTransition alloc] initWithTargetEdgeInsets:self.request.edgeInsets];
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
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"";
    request.path = [dictionary[@"path"] isKindOfClass:[NSString class]] ? dictionary[@"path"] : @"";
    request.animated = [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"animated"]).boolValue : YES;
    request.withNavigationController = [dictionary[@"withNavigationController"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"withNavigationController"]).boolValue : YES;
    NSString *edgeInsetsString = [dictionary[@"edgeInsets"] isKindOfClass:[NSString class]] ? dictionary[@"edgeInsets"] : nil;
    if (edgeInsetsString != nil) {
        request.edgeInsets = [self edgeInsetsFromString:edgeInsetsString];
        request.edgeInsetsDidSet = YES;
    }
    request.args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    return [self buildWithRequest:request];
}

- (UIEdgeInsets)edgeInsetsFromString:(NSString *)str{
    NSArray<NSString *> *arr = [str componentsSeparatedByString:@","];
    if (arr.count == 4){
        return UIEdgeInsetsMake([arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue]);
    }
    return UIEdgeInsetsZero;
}

@end
