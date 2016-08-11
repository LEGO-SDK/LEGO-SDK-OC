//
//  LGONavigationController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGONavigationController.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOViewControllerGlobalValues.h"
#import "LGOWebViewController.h"
#import "LGOWKWebView.h"

@interface LGONavigationRequest: LGORequest

@property (nonatomic, strong) NSString *opt; // push/pop
@property (nonatomic, strong) NSString *path; // an URLString or LGOViewControllerMapping[path]
@property (nonatomic, assign) BOOL animated; // push or pop need animation. Defaults to true.
@property (nonatomic, strong) NSDictionary *args; // deliver context to next ViewController

@end

@implementation LGONavigationRequest

@end

static NSDate *lastPush;

@interface LGONavigationOperation: LGORequestable

@property (nonatomic, retain) LGONavigationRequest *request;

@end

@implementation LGONavigationOperation

- (LGOResponse *)requestSynchronize{
    if ([self.request.opt isEqualToString:@"push"]){
        [self push];
    }
    else if ([self.request.opt isEqualToString:@"pop"]){
        [self pop];
    }
    return [LGOResponse new];
}

- (void)pop{
    UIViewController *requestVC = [self.request.context requestViewController];
    if (requestVC != nil && requestVC.navigationController){
        [requestVC.navigationController popViewControllerAnimated:self.request.animated];
    }
}

- (void)push{
    if (lastPush != nil && lastPush.timeIntervalSinceNow > -1.0 ){
        NSLog(@"两次 Push 的操作不能少于 1 秒");
        return;
    }
    else{
        lastPush = [NSDate new];
    }
    if (self.request.path.length > 0){
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
            [self pushWebView:URL];
        }
        else {
            LGOViewControllerInitializeBlock initBlock = [LGOViewControllerGlobalValues LGOViewControllerMapping][self.request.path];
            if (initBlock != nil){
                [self pushViewController:initBlock];
            }
        }
    }
}

- (void)pushWebView:(NSURL*)URL{
    LGOWebViewController *aWebViewController = [LGOWebViewController new];
    aWebViewController.initializeContext = self.request.args;
    aWebViewController.initializeRequest = [[NSURLRequest alloc] initWithURL:URL];
    aWebViewController.hidesBottomBarWhenPushed = YES;
    aWebViewController.title = [self.request.args[@"title"] isKindOfClass:[NSString class]]? self.request.args[@"title"]: @"";
    
    UIViewController *requestVC = [self.request.context requestViewController];
    UINavigationController *naviVC = requestVC? requestVC.navigationController : nil;
    if (naviVC == nil) { return; }
    
    if (aWebViewController.isPrerending){
        static BOOL pushed = NO;
        __weak LGOWebViewController *weakWebViewController = aWebViewController;
        aWebViewController.renderDidFinished = ^{
            LGOWebViewController *strongWebViewController = weakWebViewController;
            if (pushed || strongWebViewController == nil) {
                return ;
            }
            pushed = YES;
            [naviVC pushViewController:strongWebViewController animated:self.request.animated];
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (pushed){ return ; }
            pushed = YES;
            [naviVC pushViewController:aWebViewController animated:self.request.animated];
        });
    }
    else{
        [naviVC pushViewController:aWebViewController animated:self.request.animated];
    }
}

- (void)pushViewController:(LGOViewControllerInitializeBlock)initBlock{
    UIViewController *instance = initBlock(self.request.args);
    if (instance != nil){
        instance.title = [self.request.args[@"title"] isKindOfClass:[NSString class]]? self.request.args[@"title"]:@"";
        UIViewController *requestVC = [self.request.context requestViewController];
        UINavigationController *naviVC = requestVC? requestVC.navigationController : nil;
        if (naviVC == nil){ return ; }
        [naviVC pushViewController:instance animated:self.request.animated];
    }
}

@end

@implementation LGONavigationController

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGONavigationRequest class]]){
        LGONavigationOperation *operation = [LGONavigationOperation new];
        operation.request = (LGONavigationRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSString *opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"";
    NSString *path = [dictionary[@"path"] isKindOfClass:[NSString class]] ? dictionary[@"path"] : @"";
    BOOL animated = [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? ((NSNumber*)dictionary[@"animated"]).boolValue : YES;
    NSDictionary *args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    if (opt == nil){
        return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: opt"];
    }
    LGONavigationRequest *request = [LGONavigationRequest new];
    request.context = context;
    request.opt = opt;
    request.path = path;
    request.animated = animated;
    request.args = args;
    return [self buildWithRequest:request];
}

@end

