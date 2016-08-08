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

// Supp
@interface LGOAppFrameEntity : NSObject
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSString* framePath;
@property (nonatomic, strong) NSDictionary<NSString*, id>* frameArgs;
@end

@implementation LGOAppFrameEntity

@end

// Request
@interface LGOAppFrameRequest : LGORequest
@property (nonatomic, strong) NSArray<LGOAppFrameEntity*>* items;
@end

@implementation LGOAppFrameRequest

@end

// Operation
@interface LGOAppFrameOperation : LGORequestable
@property (nonatomic, strong) LGOAppFrameRequest *request;
@end

@implementation LGOAppFrameOperation

- (LGOResponse *)requestSynchronize{
    NSString* NavigationControllerClassName = [NSString stringWithFormat:@"%s", class_getName([UINavigationController class])] ; //@Td mergeFrom customsClass
    
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rootViewController || ![rootViewController.accessibilityLabel isEqualToString:@"AppFrame"]){ return nil; }
    
    if (self.request.items.count > 1){
        UITabBarController* tabBarController = [UITabBarController new];
        
        NSMutableArray<UIViewController*>* controllers = [NSMutableArray new];
        for (LGOAppFrameEntity* item in self.request.items) {
            UIViewController* vc1 = [self viewController:item];
            if (!vc1) continue;
            UINavigationController* naviController = [(UINavigationController*)[NSClassFromString(NavigationControllerClassName) alloc] initWithRootViewController:vc1];
            [controllers addObject:naviController];
        }
        
        [tabBarController setViewControllers:controllers animated:NO];
        tabBarController.accessibilityLabel = @"AppFrame";
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if(window){
            window.rootViewController = tabBarController;
        }
    }
    else {
        LGOAppFrameEntity* item = self.request.items.firstObject;
        UIViewController* viewController = [self viewController:item];
        if (!item || !viewController){ return nil; }
        
        UINavigationController* naviController = [(UINavigationController*)[NSClassFromString(NavigationControllerClassName) alloc] initWithRootViewController:viewController];
        naviController.accessibilityLabel = @"AppFrame";
        
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (window){
            window.rootViewController = naviController;
        }
    }
    return nil;
}

// ... supp
- (UIViewController*)viewController:(LGOAppFrameEntity*)item{
    if (!item){return nil;}
    
    NSURL* relativeURL = nil;
    UIViewController* webViewController = self.request.context.requestViewController;
    if (webViewController && [webViewController isKindOfClass:[LGOWebViewController class]]){
        UIView* webView = ((LGOWebViewController *)webViewController).webView;
        if (webView && [webView isKindOfClass:[LGOWKWebView class]]){
            relativeURL = ((LGOWKWebView*)webView).URL;
        }
    }
    if (!relativeURL) return nil;
    
    if ([LGOViewControllerGlobalValues LGOViewControllerMapping]){
        LGOViewControllerInitializeBlock initBlock = [LGOViewControllerGlobalValues LGOViewControllerMapping][item.framePath];
        if (initBlock){
            return initBlock(item.frameArgs);
        }
    }
    
    NSURL* URL = [NSURL URLWithString:item.framePath relativeToURL:relativeURL];
    if (!URL) return nil;
    LGOWebViewController* aWebViewController = [LGOWebViewController new];
    aWebViewController.initializeContext = item.frameArgs;
    aWebViewController.initializeRequest = [[NSURLRequest alloc] initWithURL:URL];
    aWebViewController.title = [item.frameArgs[@"title"] isKindOfClass:[NSString class]]?item.frameArgs[@"title"]:@"";
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        UITabBarItem* tabItem = [self requestTabItem:item];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            aWebViewController.tabBarItem = tabItem;
        }];
    }];
    
    return aWebViewController;
}

- (UITabBarItem*)requestTabItem:(LGOAppFrameEntity*)item{
    NSString* icon = item.icon;
    if (!icon) return nil;
    NSURL* iconURL = [NSURL URLWithString:icon];
    if(!iconURL) return nil;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:iconURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    UIImage* image = [UIImage imageWithData:data scale:2.0];
    if (!image) return nil;
    NSString* title = [item.frameArgs[@"title"] isKindOfClass:[NSString class]]? item.frameArgs[@"title"] : nil;
    return [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
}

@end

// Module
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
    NSArray<NSDictionary*>* items = [dictionary[@"items"] isKindOfClass:[NSArray class]] ? dictionary[@"items"] : nil;
    if (!items){
        return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: items"];
    }
    
    NSMutableArray<LGOAppFrameEntity*>* itemFormatted = [NSMutableArray new];
    for (NSDictionary* item in items) {
        NSString* framePath = [item[@"framePath"] isKindOfClass:[NSString class]] ? item[@"framePath"] : nil;
        if (!framePath) continue;
        
        LGOAppFrameEntity* entity = [LGOAppFrameEntity new];
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

