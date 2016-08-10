//
//  LGOStatusBar.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOStatusBar.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOWebViewController.h"

@interface LGOStatusBarRequest : LGORequest

@property (nonatomic, strong) NSString *style; // light/default

@end

@implementation LGOStatusBarRequest

@end

@interface LGOStatusBarOperation : LGORequestable

@property (nonatomic, strong) LGOStatusBarRequest *request;

@end

@implementation LGOStatusBarOperation

- (void)updateInitContext{
    UIViewController *viewController = [self.request.context requestViewController];
    if ([viewController isKindOfClass:[LGOWebViewController class]]){
        NSDictionary *initialzeContext = ((LGOWebViewController *)viewController).initializeContext;
        if (initialzeContext != nil){
            [initialzeContext setValue:self.request.style forKey:@"statusBarStyle"];
            ((LGOWebViewController *)viewController).initializeContext = initialzeContext;
            [viewController setNeedsStatusBarAppearanceUpdate];
        }
    }
}

-(LGOResponse *)requestSynchronize{
    NSDictionary *value = [NSBundle mainBundle].infoDictionary[@"UIViewControllerBasedStatusBarAppearance"] ;
    if ([value isKindOfClass:[NSNumber class]]){
        if (((NSNumber *)value).boolValue){
            [[UIApplication sharedApplication] setStatusBarStyle: [self.request.style isEqualToString:@"light"]? UIStatusBarStyleLightContent : UIStatusBarStyleDefault animated:YES];
        }
        else {
            [self updateInitContext];
        }
    }
    else {
        [self updateInitContext];
    }
    return [LGOResponse new];
}

@end

@implementation LGOStatusBar

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOStatusBarRequest class]]){
        LGOStatusBarOperation *operation = [LGOStatusBarOperation new];
        operation.request = (LGOStatusBarRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    NSString *style = [dictionary[@"style"] isKindOfClass:[NSString class]] ? dictionary[@"style"] : nil;
    if (style == nil){
        return [[LGOBuildFailed alloc] initWithErrorString:@"RequestParam Required: style"];
    }
    LGOStatusBarRequest *request = [LGOStatusBarRequest new];
    request.context = context;
    request.style = style;
    return [self buildWithRequest:request];
}

@end

