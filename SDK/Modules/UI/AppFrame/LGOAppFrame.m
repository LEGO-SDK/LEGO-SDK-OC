//
//  LGOAppFrame.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "LGOAppFrame.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOWebViewController.h"
#import "LGOWKWebView.h"
#import "LGOViewControllerGlobalValues.h"

@interface LGOAppFrameEntity : NSObject

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *framePath;
@property (nonatomic, strong) NSDictionary<NSString*, id> *frameArgs;

@end

@implementation LGOAppFrameEntity

@end

@interface LGOAppFrameRequest: LGORequest

@property (nonatomic, strong) NSArray<LGOAppFrameEntity*> *items;

@end

@implementation LGOAppFrameRequest

@end

@interface LGOAppFrameOperation: LGORequestable

@property (nonatomic, strong) LGOAppFrameRequest *request;

@end

@implementation LGOAppFrameOperation

- (LGOResponse *)requestSynchronize{
    NSString *NavigationControllerClassName = [NSString stringWithFormat:@"%s", class_getName([UINavigationController class])];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController == nil || ![rootViewController.accessibilityLabel isEqualToString:@"AppFrame"]){ return nil; }
    
    if (self.request.items.count > 1){
        UITabBarController *tabBarController = [UITabBarController new];
        
        NSMutableArray<UIViewController*> *controllers = [NSMutableArray new];
        for (LGOAppFrameEntity *item in self.request.items) {
            UIViewController *vc1 = [self viewController:item];
            if (vc1 == nil) continue;
            UINavigationController *naviController = [(UINavigationController*)[NSClassFromString(NavigationControllerClassName) alloc] initWithRootViewController:vc1];
            [controllers addObject:naviController];
        }
        
        [tabBarController setViewControllers:controllers animated:NO];
        tabBarController.accessibilityLabel = @"AppFrame";
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if(window){
            window.rootViewController = tabBarController;
        }
    }
    else {
        LGOAppFrameEntity *item = self.request.items.firstObject;
        UIViewController *viewController = [self viewController:item];
        if (item == nil || !viewController){ return nil; }
        
        UINavigationController *naviController = [(UINavigationController *)[NSClassFromString(NavigationControllerClassName) alloc] initWithRootViewController:viewController];
        naviController.accessibilityLabel = @"AppFrame";
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window != nil){
            window.rootViewController = naviController;
        }
    }
    return nil;
}

- (UIViewController *)viewController:(LGOAppFrameEntity *)item{
    if (item == nil){return nil;}
    
    NSURL *relativeURL = nil;
    UIViewController *webViewController = self.request.context.requestViewController;
    if (webViewController != nil && [webViewController isKindOfClass:[LGOWebViewController class]]){
        UIView *webView = ((LGOWebViewController *)webViewController).webView;
        if (webView != nil && [webView isKindOfClass:[LGOWKWebView class]]){
            relativeURL = ((LGOWKWebView*)webView).URL;
        }
    }
    if (relativeURL == nil) return nil;
    
    if ([LGOViewControllerGlobalValues LGOViewControllerMapping]){
        LGOViewControllerInitializeBlock initBlock = [LGOViewControllerGlobalValues LGOViewControllerMapping][item.framePath];
        if (initBlock){
            return initBlock(item.frameArgs);
        }
    }
    
    NSURL *URL = [NSURL URLWithString:item.framePath relativeToURL:relativeURL];
    if (URL == nil) return nil;
    LGOWebViewController *aWebViewController = [LGOWebViewController new];
    aWebViewController.initializeContext = item.frameArgs;
    aWebViewController.initializeRequest = [[NSURLRequest alloc] initWithURL:URL];
    aWebViewController.title = [item.frameArgs[@"title"] isKindOfClass:[NSString class]]?item.frameArgs[@"title"]:@"";
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        UITabBarItem *tabItem = [self requestTabItem:item];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            aWebViewController.tabBarItem = tabItem;
        }];
    }];
    
    return aWebViewController;
}

- (UITabBarItem *)requestTabItem:(LGOAppFrameEntity *)item{
    NSString *icon = item.icon;
    if (icon == nil) return nil;
    NSURL *iconURL = [NSURL URLWithString:icon];
    if(iconURL == nil) return nil;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:iconURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    UIImage *image = [UIImage imageWithData:data scale:2.0];
    if (image == nil) return nil;
    NSString *title = [item.frameArgs[@"title"] isKindOfClass:[NSString class]]? item.frameArgs[@"title"] : nil;
    return [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
}

@end

@implementation LGOAppFrame

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOAppFrameRequest class]]){
        LGOAppFrameOperation *operation = [LGOAppFrameOperation new];
        operation.request = (LGOAppFrameRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSArray<NSDictionary*> *items = [dictionary[@"items"] isKindOfClass:[NSArray class]] ? dictionary[@"items"] : nil;
    if (items == nil){
        return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: items"];
    }
    
    NSMutableArray<LGOAppFrameEntity*> *itemFormatted = [NSMutableArray new];
    for (NSDictionary* item in items) {
        NSString *framePath = [item[@"framePath"] isKindOfClass:[NSString class]] ? item[@"framePath"] : nil;
        if (framePath == nil) continue;
        
        LGOAppFrameEntity *entity = [LGOAppFrameEntity new];
        entity.icon = [item[@"icon"] isKindOfClass:[NSString class]] ? item[@"icon"] : nil;
        entity.framePath = framePath;
        entity.frameArgs = [item[@"frameArgs"] isKindOfClass:[NSDictionary class]] ? item[@"frameArgs"] : nil;
        [itemFormatted addObject:entity];
    }
    
    LGOAppFrameRequest *request = [LGOAppFrameRequest new];
    request.context = context;
    request.items = itemFormatted;
    return [self buildWithRequest:request];
}

@end

