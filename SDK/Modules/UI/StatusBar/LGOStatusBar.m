//
//  LGOStatusBar.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOStatusBar.h"
#import "UIViewController+LGOStatusBar.h"

@interface LGOStatusBarRequest : LGORequest

@property(nonatomic, strong) NSString *style;   // light/default
@property(nonatomic, strong) NSNumber *hidden;  // boolean
@property(nonatomic, assign) BOOL animated;     // boolean

@end

@implementation LGOStatusBarRequest

@end

@interface LGOStatusBarOperation : LGORequestable

@property(nonatomic, strong) LGOStatusBarRequest *request;

@end

@implementation LGOStatusBarOperation

- (void)updatePreference:(UIViewController *)viewController {
    if (self.request.animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                           [viewController setNeedsStatusBarAppearanceUpdate];
                         }];
    } else {
        [viewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (LGOResponse *)requestSynchronize {
    UIViewController *viewController = [self.request.context requestViewController];
    if (viewController.tabBarController != nil &&
        viewController.tabBarController.selectedViewController != viewController &&
        viewController.tabBarController.selectedViewController != viewController.navigationController) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.StatusBar"
                                                             code:-3
                                                         userInfo:@{
                                                                    NSLocalizedDescriptionKey : @"Current request ViewController in-actived."
                                                                    }]];;
    }
    if (viewController.navigationController != nil &&
        viewController.navigationController.visibleViewController != viewController) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.StatusBar"
                                                             code:-3
                                                         userInfo:@{
                                                                    NSLocalizedDescriptionKey : @"Current request ViewController in-actived."
                                                                    }]];;
    }
    if (viewController != nil) {
        if ([self.request.style isEqualToString:@"light"]) {
            viewController.lgo_statusBarStyle = UIStatusBarStyleLightContent;
        } else if (self.request.style != nil) {
            viewController.lgo_statusBarStyle = UIStatusBarStyleDefault;
        }
        if ([self.request.hidden isEqualToNumber:@(YES)]) {
            viewController.lgo_statusBarHidden = YES;
        } else if (self.request.hidden != nil) {
            viewController.lgo_statusBarHidden = NO;
        }
        NSDictionary *value = [NSBundle mainBundle].infoDictionary[@"UIViewControllerBasedStatusBarAppearance"];
        if ([value isKindOfClass:[NSNumber class]]) {
            if (!((NSNumber *)value).boolValue) {
                [viewController lgo_setNeedsStatusBarAppearanceUpdate:self.request.animated];
            } else {
                [self updatePreference:viewController];
            }
        } else {
            [self updatePreference:viewController];
        }
        return [[LGOResponse new] accept:nil];
    }
    return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.StatusBar"
                                                         code:-2
                                                     userInfo:@{
                                                         NSLocalizedDescriptionKey : @"ViewController not found."
                                                     }]];
}

@end

@implementation LGOStatusBar

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.StatusBar" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOStatusBarRequest class]]) {
        LGOStatusBarOperation *operation = [LGOStatusBarOperation new];
        operation.request = (LGOStatusBarRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.StatusBar" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOStatusBarRequest *request = [LGOStatusBarRequest new];
    request.context = context;
    request.style = [dictionary[@"style"] isKindOfClass:[NSString class]] ? dictionary[@"style"] : nil;
    request.hidden = [dictionary[@"hidden"] isKindOfClass:[NSNumber class]] ? dictionary[@"hidden"] : nil;
    request.animated =
        [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? [dictionary[@"animated"] boolValue] : YES;
    return [self buildWithRequest:request];
}

@end
