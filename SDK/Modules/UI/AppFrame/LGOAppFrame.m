//
//  LGOAppFrame.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "LGOAppFrame.h"
#import "LGOBuildFailed.h"
#import "LGOCore.h"
#import "UIViewController+LGOViewController.h"

@interface LGOAppFrameEntity : NSObject

@property(nonatomic, strong) NSString *path;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSString *icon;
@property(nonatomic, assign) BOOL statusBarHidden;
@property(nonatomic, assign) BOOL navigationBarHidden;
@property(nonatomic, strong) NSDictionary *args;

@end

@implementation LGOAppFrameEntity

@end

@interface LGOAppFrameRequest : LGORequest

@property(nonatomic, strong) NSArray<LGOAppFrameEntity *> *items;

@end

@implementation LGOAppFrameRequest

@end

@interface LGOAppFrameOperation : LGORequestable

@property(nonatomic, strong) LGOAppFrameRequest *request;

@end

@implementation LGOAppFrameOperation

- (LGOResponse *)requestSynchronize {
    NSString *NavigationControllerClassName =
        [NSString stringWithFormat:@"%s", class_getName([UINavigationController class])];

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController == nil || ![rootViewController.accessibilityLabel isEqualToString:@"AppFrame"]) {
        return nil;
    }

    if (self.request.items.count > 1) {
        UITabBarController *tabBarController = [UITabBarController new];

        NSMutableArray<UIViewController *> *controllers = [NSMutableArray new];
        for (LGOAppFrameEntity *item in self.request.items) {
            UIViewController *vc1 = [self viewController:item];
            if (vc1 == nil) continue;
            UINavigationController *naviController =
                [(UINavigationController *)[NSClassFromString(NavigationControllerClassName) alloc]
                    initWithRootViewController:vc1];
            [controllers addObject:naviController];
        }

        [tabBarController setViewControllers:controllers animated:NO];
        tabBarController.accessibilityLabel = @"AppFrame";
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            window.rootViewController = tabBarController;
        }
    } else {
        LGOAppFrameEntity *item = self.request.items.firstObject;
        UIViewController *viewController = [self viewController:item];
        if (item == nil || !viewController) {
            return nil;
        }

        UINavigationController *naviController =
            [(UINavigationController *)[NSClassFromString(NavigationControllerClassName) alloc]
                initWithRootViewController:viewController];
        naviController.accessibilityLabel = @"AppFrame";

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window != nil) {
            window.rootViewController = naviController;
        }
    }
    return nil;
}

- (UIViewController *)viewController:(LGOAppFrameEntity *)item {
    if (item == nil) {
        return nil;
    }
    NSURL *relativeURL = nil;
    UIView *webView = self.request.context.requestWebView;
    if (webView != nil && [webView isKindOfClass:[UIWebView class]]) {
        relativeURL = ((UIWebView *)webView).request.URL;
    }
    if (webView != nil && [webView isKindOfClass:[WKWebView class]]) {
        relativeURL = ((WKWebView *)webView).URL;
    }
    NSURL *URL = [NSURL URLWithString:item.path relativeToURL:relativeURL];
    if (URL == nil) {
        return nil;
    }
    UIViewController *nextViewController = [UIViewController new];
    [nextViewController lgo_openWebViewWithRequest:[[NSURLRequest alloc] initWithURL:URL] args:item.args];
    nextViewController.title = item.title;
    if ([nextViewController respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")]) {
        [nextViewController setValue:@(item.navigationBarHidden) forKey:@"lgo_navigationBarHidden"];
    }
    if ([nextViewController respondsToSelector:NSSelectorFromString(@"lgo_statusBarHidden")]) {
        [nextViewController setValue:@(item.statusBarHidden) forKey:@"lgo_statusBarHidden"];
    }
    [[NSOperationQueue new] addOperationWithBlock:^{
      UITabBarItem *tabItem = [self requestTabItem:item];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        nextViewController.tabBarItem = tabItem;
      }];
    }];
    return nextViewController;
}

- (UITabBarItem *)requestTabItem:(LGOAppFrameEntity *)item {
    NSString *icon = item.icon;
    if (icon == nil) {
        return nil;
    }
    NSURL *iconURL = [NSURL URLWithString:icon];
    if (iconURL == nil) {
        return nil;
    }
    NSURLRequest *request =
        [[NSURLRequest alloc] initWithURL:iconURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:data scale:2.0];
    if (image == nil) {
        return nil;
    }
    NSString *title = item.title;
    return [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
}

@end

@implementation LGOAppFrame

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOAppFrameRequest class]]) {
        LGOAppFrameOperation *operation = [LGOAppFrameOperation new];
        operation.request = (LGOAppFrameRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSArray<NSDictionary *> *items = [dictionary[@"items"] isKindOfClass:[NSArray class]] ? dictionary[@"items"] : nil;
    if (items == nil) {
        return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: items"];
    }

    NSMutableArray<LGOAppFrameEntity *> *itemFormatted = [NSMutableArray new];
    for (NSDictionary *item in items) {
        LGOAppFrameEntity *entity = [LGOAppFrameEntity new];
        entity.path = [item[@"path"] isKindOfClass:[NSString class]] ? item[@"path"] : nil;
        entity.title = [item[@"title"] isKindOfClass:[NSString class]] ? item[@"title"] : nil;
        entity.icon = [item[@"icon"] isKindOfClass:[NSString class]] ? item[@"icon"] : nil;
        entity.statusBarHidden =
            [item[@"statusBarHidden"] isKindOfClass:[NSNumber class]] ? [item[@"statusBarHidden"] boolValue] : NO;
        entity.navigationBarHidden = [item[@"navigationBarHidden"] isKindOfClass:[NSNumber class]]
                                         ? [item[@"navigationBarHidden"] boolValue]
                                         : NO;
        entity.args = [item[@"args"] isKindOfClass:[NSDictionary class]] ? item[@"args"] : nil;
        [itemFormatted addObject:entity];
    }

    LGOAppFrameRequest *request = [LGOAppFrameRequest new];
    request.context = context;
    request.items = itemFormatted;
    return [self buildWithRequest:request];
}

@end
