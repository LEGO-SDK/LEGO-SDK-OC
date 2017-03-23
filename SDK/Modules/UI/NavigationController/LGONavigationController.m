//
//  LGONavigationController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "LGOCore.h"
#import "LGONavigationController.h"
#import "UIViewController+LGOViewController.h"

@interface LGONavigationRequest : LGORequest

@property(nonatomic, copy) NSString *opt;               // push/pop.
@property(nonatomic, copy) NSString *path;              // an URLString.
@property(nonatomic, assign) BOOL animated;             // push or pop need animation. Defaults to true.
@property(nonatomic, copy) NSString *title;             // next title.
@property(nonatomic, assign) BOOL statusBarHidden;      // next statusBarHidden.
@property(nonatomic, copy) NSString *statusBarStyle;    // next statusBarStyle.
@property(nonatomic, assign) BOOL navigationBarHidden;  // next navigationBarHidden.
@property(nonatomic, copy) NSDictionary *args;          // deliver context to next ViewController.

@end

@implementation LGONavigationRequest

@end

static NSDate *lastPush;

@interface LGONavigationOperation : LGORequestable

@property(nonatomic, retain) LGONavigationRequest *request;

@end

@implementation LGONavigationOperation

- (LGOResponse *)requestSynchronize {
    if ([self.request.opt isEqualToString:@"push"]) {
        return [self push];
    } else if ([self.request.opt isEqualToString:@"pop"]) {
        return [self pop];
    }
    return [LGOResponse new];
}

- (LGOResponse *)pop {
    UIViewController *requestVC = [self.request.context requestViewController];
    if (requestVC != nil && requestVC.navigationController) {
        [requestVC.navigationController popViewControllerAnimated:self.request.animated];
        return [[LGOResponse new] accept:nil];
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.NavigationController"
                                                             code:-2
                                                         userInfo:@{
                                                                    NSLocalizedDescriptionKey : @"ViewController not found."
                                                                    }]];
    }
}

- (LGOResponse *)push {
    if (lastPush != nil && lastPush.timeIntervalSinceNow > -1.0) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.NavigationController"
                                                             code:-3
                                                         userInfo:@{
                                                                    NSLocalizedDescriptionKey : @"push interval too short."
                                                                    }]];
    } else {
        lastPush = [NSDate new];
    }
    if (self.request.path.length > 0) {
        NSURL *relativeURL = nil;
        UIView *webView = self.request.context.requestWebView;
        if (webView != nil && [webView isKindOfClass:[UIWebView class]]) {
            relativeURL = ((UIWebView *)webView).request.URL;
        }
        if (webView != nil && [webView isKindOfClass:[WKWebView class]]) {
            relativeURL = ((WKWebView *)webView).URL;
        }
        NSURL *URL = [NSURL URLWithString:self.request.path relativeToURL:relativeURL];
        if (URL != nil) {
            return [self pushWebView:URL];
        } else {
            return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.NavigationController"
                                                                 code:-5
                                                             userInfo:@{
                                                                        NSLocalizedDescriptionKey : @"invalid url."
                                                                        }]];
        }
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.NavigationController"
                                                             code:-5
                                                         userInfo:@{
                                                                    NSLocalizedDescriptionKey : @"null path"
                                                                    }]];
    }
}

- (LGOResponse *)pushWebView:(NSURL *)URL {
    UIViewController *nextViewController = [UIViewController new];
    nextViewController.hidesBottomBarWhenPushed = YES;
    nextViewController.title = self.request.title;
    if ([nextViewController respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")]) {
        [nextViewController setValue:@(self.request.navigationBarHidden) forKey:@"lgo_navigationBarHidden"];
    }
    if ([nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarHidden")]) {
        [nextViewController setValue:@(self.request.statusBarHidden) forKey:@"lgo_statusBarHidden"];
    }
    if ([self.request.statusBarStyle isEqualToString:@"light"] &&
        [nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarStyle")]) {
        [nextViewController setValue:@(UIStatusBarStyleLightContent) forKey:@"lgo_statusBarStyle"];
    }
    else if ([self.request.statusBarStyle isEqualToString:@"default"] &&
             [nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarStyle")]) {
        [nextViewController setValue:@(UIStatusBarStyleDefault) forKey:@"lgo_statusBarStyle"];
    }
    else if (self.request.statusBarStyle != nil &&
             [nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarStyle")]) {
        [nextViewController setValue:[[self.request.context requestViewController] valueForKey:@"lgo_statusBarStyle"] forKey:@"lgo_statusBarStyle"];
    }
    UINavigationController *navigationController = [[self.request.context requestViewController] navigationController];
    if (navigationController == nil) {
        return
        [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.NavigationController"
                                                      code:-4
                                                  userInfo:@{
                                                             NSLocalizedDescriptionKey : @"NavigationController not found."
                                                             }]];
    }
    [navigationController pushViewController:nextViewController animated:self.request.animated];
    [nextViewController.view setBackgroundColor:[UIColor whiteColor]];
    BOOL lgo_statusBarHidden = [nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarHidden")] &&
    [[nextViewController valueForKey:@"lgo_statusBarHidden"] boolValue] != [[[self.request.context requestViewController] valueForKey:@"lgo_statusBarHidden"] boolValue];
    BOOL lgo_navigationBarHidden = [nextViewController respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")] &&
    [[nextViewController valueForKey:@"lgo_navigationBarHidden"] boolValue] != [[[self.request.context requestViewController] valueForKey:@"lgo_navigationBarHidden"] boolValue];
    if (lgo_statusBarHidden || lgo_navigationBarHidden) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [nextViewController lgo_openWebViewWithRequest:[[NSURLRequest alloc] initWithURL:URL] args:self.request.args];
        });
    }
    else {
        [nextViewController lgo_openWebViewWithRequest:[[NSURLRequest alloc] initWithURL:URL] args:self.request.args];
    }
    return [[LGOResponse new] accept:nil];
}

@end

@implementation LGONavigationController

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.NavigationController" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGONavigationRequest class]]) {
        LGONavigationOperation *operation = [LGONavigationOperation new];
        operation.request = (LGONavigationRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.NavigationController" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGONavigationRequest *request = [LGONavigationRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"push";
    request.path = [dictionary[@"path"] isKindOfClass:[NSString class]] ? dictionary[@"path"] : @"";
    request.animated = [dictionary[@"animated"] isKindOfClass:[NSNumber class]]
    ? ((NSNumber *)dictionary[@"animated"]).boolValue
    : YES;
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : @"";
    request.statusBarHidden = [dictionary[@"statusBarHidden"] isKindOfClass:[NSNumber class]]
    ? [dictionary[@"statusBarHidden"] boolValue]
    : NO;
    request.statusBarStyle = [dictionary[@"statusBarStyle"] isKindOfClass:[NSString class]] ? dictionary[@"statusBarStyle"] : nil;
    request.navigationBarHidden = [dictionary[@"navigationBarHidden"] isKindOfClass:[NSNumber class]]
    ? [dictionary[@"navigationBarHidden"] boolValue]
    : NO;
    request.args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    return [self buildWithRequest:request];
}

@end
