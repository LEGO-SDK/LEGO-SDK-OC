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
            if ([self.request.args[@"customID"] isEqualToString:@"root"]) {
                [requestVC.navigationController popToRootViewControllerAnimated:self.request.animated];
                return [[LGOResponse new] accept:nil];
            }
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
    NSString *imgBase64 = @"iVBORw0KGgoAAAANSUhEUgAAAEIAAABCCAYAAADjVADoAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyhpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMDY3IDc5LjE1Nzc0NywgMjAxNS8wMy8zMC0yMzo0MDo0MiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKE1hY2ludG9zaCkiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NTVCNkJDQTgwNkNFMTFFNzg5ODRERDBCODBDNzI0RTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NTVCNkJDQTkwNkNFMTFFNzg5ODRERDBCODBDNzI0RTMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo1NUI2QkNBNjA2Q0UxMUU3ODk4NEREMEI4MEM3MjRFMyIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo1NUI2QkNBNzA2Q0UxMUU3ODk4NEREMEI4MEM3MjRFMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgycSQAAAAGeSURBVHja7Nw9bsJAEAXgdUifnAWuQI1ECsocgYo+hJYTUOYMtOlTRbkKOQAyYxGkFDYumJ/3PIz0JETh4pOR1zuzVHVdl3uV8nAn4IZYSD4kS8lI44KPhAhvkvXf51fJs2ST7Y74j3CpWbafRhtCUz+ZILoQviWrLBDXEKaS3wwQfQiHDI9PNwRkCFcEVAh3BESIEAQ0iDAEJIhQBBSIcAQECAiEaAgYhEgIKIQoCDiECAhIBG8IWARPCGgELwh4BA8ICgRrCBoESwgqBCsIOgQLCEoEbQhaBE0IagQtCHoEDYhBIGhAVGUgdStEcze8t3w/kXyWc8s+BcRgMLSeGvQYmusIagztlSUthsW7BiWG1dsnHYblfgQVhvUOFQ2Gx54lBYbXLjY8hmdfAxrDu9MFixHR+4TEiOqGw2FEzkdAYURPzMBgIMxQQWCgTNWFYyDNWYZioE3ehmEgzmKHYKBO57tjIJ/XcMVAP8HjhsFwpqsP4ykLRB/GNhPENYxxNogujL3GhSvSv014kcwlX5Kd5JgVIs2Cyr1OAgwA39mb1P3SNzkAAAAASUVORK5CYII=";
    NSData * imageData =[[NSData alloc] initWithBase64EncodedString:imgBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:imageData scale:3];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                             style:UIBarButtonItemStylePlain
                             target:nextViewController
                             action:@selector(popViewController)];
    nextViewController.navigationItem.leftBarButtonItem = item;
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
