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
#import "LGOBaseViewController.h"

@interface LGONavigationRequest : LGORequest

@property(nonatomic, copy) NSString *opt;               // push/pop.
@property(nonatomic, copy) NSString *path;              // an URLString.
@property(nonatomic, assign) BOOL animated;             // push or pop need animation. Defaults to true.
@property(nonatomic, copy) NSDictionary *args;          // deliver context to next ViewController.
@property(nonatomic, copy) NSString *preloadToken;      // token for LGOPreload

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
        if (self.request.args[@"customID"] != nil) {
            for (UIViewController *vc in requestVC.navigationController.childViewControllers) {
                if ([vc isKindOfClass:[LGOBaseViewController class]]) {
                    LGOBaseViewController *lgoVC = (LGOBaseViewController *)vc;
                    if (lgoVC.args[@"customID"]!= nil && [lgoVC.args[@"customID"]  isEqual:self.request.args[@"customID"]]) {
                        [requestVC.navigationController popToViewController:lgoVC animated:self.request.animated];
                        return [[LGOResponse new] accept:nil];
                    }
                }
            }
        }
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
    LGOBaseViewController *nextViewController = [LGOBaseViewController new];
    nextViewController.hidesBottomBarWhenPushed = YES;
    nextViewController.url = URL;
    nextViewController.args = self.request.args;
    nextViewController.preloadToken = self.request.preloadToken;
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
    request.args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    request.preloadToken = [dictionary[@"preloadToken"] isKindOfClass:[NSString class]] ? dictionary[@"preloadToken"] : nil;
    return [self buildWithRequest:request];
}

@end
