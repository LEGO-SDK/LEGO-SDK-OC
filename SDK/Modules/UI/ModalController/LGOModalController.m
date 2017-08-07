//
//  LGOModalController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "LGOCore.h"
#import "LGOModalController.h"
#import "LGOBaseNavigationController.h"
#import "LGOBaseViewController.h"

typedef enum : NSUInteger {
    LGOModalTypeNormal = 0,
    LGOModalTypeCenter = 1,
    LGOModalTypeTop = 2,
    LGOModalTypeLeft = 3,
    LGOModalTypeBottom = 4,
    LGOModalTypeRight = 5,
} LGOModalType;

@interface LGOModalStyle : NSObject

@property (nonatomic, assign) LGOModalType type;
@property (nonatomic, assign) CGSize size;

@end

@implementation LGOModalStyle

@end

@interface LGOModalRequest : LGORequest

@property(nonatomic, copy) NSString *opt;               // present/dismiss
@property(nonatomic, copy) NSString *path;              // an URLString or LGOViewControllerMapping[path]
@property(nonatomic, assign) BOOL animated;             // push or pop need animation. Defaults to true.
@property(nonatomic, assign) BOOL clearWebView;         // webview background should be cleared.
@property(nonatomic, assign) BOOL clearMask;            // maskview background should be cleared.
@property(nonatomic, assign) BOOL nonMask;              // maskview will not be rended.
@property(nonatomic, strong) NSDictionary *args;        // deliver args to next ViewController
@property(nonatomic, strong) LGOModalStyle *modalStyle; // next modal style.
@property(nonatomic, copy) NSString *preloadToken;      // token for LGOPreload

@end

@implementation LGOModalRequest

- (LGOModalStyle *)modalStyle {
    if (_modalStyle == nil) {
        _modalStyle = [LGOModalStyle new];
    }
    return _modalStyle;
}

@end

@class LGOModalOperation;

LGOModalOperation *lastOperation;

NSDate *lastPresent;

@interface LGOModalOperation : LGORequestable<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning> {
    BOOL _presented;
}

@property(nonatomic, strong) LGOModalRequest *request;

@end

@implementation LGOModalOperation

- (LGOResponse *)requestSynchronize {
    if ([self.request.opt isEqualToString:@"present"]) {
        return [self present];
    } else if ([self.request.opt isEqualToString:@"dismiss"]) {
        return [self dismiss];
    }
    return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.ModalController"
                                                         code:-2
                                                     userInfo:@{
                                                         NSLocalizedDescriptionKey : @"invalid opt value."
                                                     }]];
}

- (LGOResponse *)dismiss {
    UIViewController *viewController = [self requestViewController];
    if (viewController == nil) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.ModalController"
                                                             code:-3
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"ViewController not found."
                                                         }]];
    }
    UIViewController *presentedViewController = viewController.presentedViewController;
    if (presentedViewController != nil) {
        [presentedViewController dismissViewControllerAnimated:self.request.animated completion:nil];
        return [[LGOResponse new] accept:nil];
    }
    UINavigationController *naviViewController = viewController.navigationController;
    if (naviViewController != nil) {
        [naviViewController dismissViewControllerAnimated:self.request.animated completion:nil];
        return [[LGOResponse new] accept:nil];
    }
    if (viewController.presentingViewController != nil) {
        [viewController dismissViewControllerAnimated:self.request.animated completion:nil];
    }
    return [[LGOResponse new] accept:nil];
}

- (LGOResponse *)present {
    if (lastPresent != nil && [lastPresent timeIntervalSinceNow] > -1.0) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.ModalController"
                                                             code:-4
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"present interval too short."
                                                         }]];
    } else {
        lastOperation = self;
        lastPresent = [NSDate new];
    }
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
        return [self presentWebView:URL];
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.ModalController"
                                                             code:-5
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"invalid url."
                                                         }]];
    }
}

- (LGOResponse *)presentWebView:(NSURL *)URL {
    UIViewController *viewController = [self requestViewController];
    if (viewController == nil) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.ModalController"
                                                             code:-3
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"ViewController not found."
                                                         }]];
    }
    LGOBaseViewController *nextViewController = [LGOBaseViewController new];
    nextViewController.url = URL;
    nextViewController.args = self.request.args;
    nextViewController.preloadToken = self.request.preloadToken;
    UIViewController *presentingViewController = nextViewController;
    UINavigationController *navigationController = [self requestNavigationController:nextViewController];
    if (navigationController != nil) {
        presentingViewController = navigationController;
    } else {
        presentingViewController = nextViewController;
    }
    if (self.request.modalStyle.type != LGOModalTypeNormal) {
        presentingViewController.modalPresentationStyle = UIModalPresentationCustom;
        presentingViewController.transitioningDelegate = self;
    }
    if (self.request.clearWebView) {
        [nextViewController.webView setOpaque:NO];
        [nextViewController.webView setBackgroundColor:[UIColor clearColor]];
        [nextViewController.view setBackgroundColor:[UIColor clearColor]];
        [presentingViewController.view setBackgroundColor:[UIColor clearColor]];
    }
    [viewController presentViewController:presentingViewController animated:YES completion:nil];
    return [[LGOResponse new] accept:nil];
}

- (UINavigationController *)requestNavigationController:(UIViewController *)rootViewController {
    UIViewController *requestVC = [self requestViewController];
    if (requestVC != nil && requestVC.navigationController != nil) {
        Class naviClz = [requestVC.navigationController class];
        UINavigationController *naviController = [[naviClz alloc] init];
        [naviController setViewControllers:@[ rootViewController ] animated:NO];
        return naviController;
    }
    return [[LGOBaseNavigationController alloc] initWithRootViewController:rootViewController];
}

- (UIViewController *)requestViewController {
    UIView *view =
        [self.request.context.sender isKindOfClass:[UIView class]] ? (UIView *)self.request.context.sender : nil;
    if (view) {
        UIResponder *next = [view nextResponder];
        for (int count = 0; count < 100; count++) {
            if ([next isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)next;
            } else {
                if (next != nil) {
                    next = [next nextResponder];
                }
            }
        }
    }
    return nil;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (!_presented) {
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        UIView *containerView = [transitionContext containerView];
        UIView *maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.userInteractionEnabled = YES;
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
        maskView.tag = 9999;
        maskView.backgroundColor = self.request.clearMask ? [UIColor clearColor] : [UIColor colorWithWhite:0.0 alpha:0.75];
        maskView.hidden = self.request.nonMask;
        [containerView addSubview:maskView];
        [containerView addSubview:toView];
        if (self.request.modalStyle.type == LGOModalTypeCenter) {
            toView.layer.cornerRadius = 8.0;
            toView.layer.masksToBounds = YES;
            [toView setFrame:CGRectMake((containerView.bounds.size.width - self.request.modalStyle.size.width) / 2.0,
                                        (containerView.bounds.size.height - self.request.modalStyle.size.height) / 2.0,
                                        self.request.modalStyle.size.width,
                                        self.request.modalStyle.size.height)];
            [toView setTransform:CGAffineTransformMake(0.75, 0.0, 0.0, 0.75, 0.0, 0.0)];
            toView.alpha = 0.0;
            maskView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)];
                toView.alpha = 1.0;
                maskView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeTop) {
            [toView setFrame:CGRectMake(0.0,
                                        0.0,
                                        containerView.bounds.size.width,
                                        self.request.modalStyle.size.height)];
            [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, -self.request.modalStyle.size.height)];
            maskView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)];
                maskView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeBottom) {
            [toView setFrame:CGRectMake(0.0,
                                        containerView.bounds.size.height - self.request.modalStyle.size.height,
                                        containerView.bounds.size.width,
                                        self.request.modalStyle.size.height)];
            [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, self.request.modalStyle.size.height)];
            maskView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)];
                maskView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeLeft) {
            [toView setFrame:CGRectMake(0.0,
                                        0.0,
                                        self.request.modalStyle.size.width,
                                        containerView.bounds.size.height)];
            [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, -self.request.modalStyle.size.width, 0.0)];
            maskView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)];
                maskView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeRight) {
            [toView setFrame:CGRectMake(containerView.bounds.size.width - self.request.modalStyle.size.width,
                                        0.0,
                                        self.request.modalStyle.size.width,
                                        containerView.bounds.size.height)];
            [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, self.request.modalStyle.size.width, 0.0)];
            maskView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                [toView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)];
                maskView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        _presented = YES;
    }
    else {
        UIView *containerView = [transitionContext containerView];
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        UIView *maskView = [containerView viewWithTag:9999];
        if (self.request.modalStyle.type == LGOModalTypeCenter) {
            fromView.alpha = 1.0;
            maskView.alpha = 1.0;
            [UIView animateWithDuration:0.25 animations:^{
                fromView.alpha = 0.0;
                maskView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeTop) {
            maskView.alpha = 1.0;
            [UIView animateWithDuration:0.25 animations:^{
                [fromView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, -fromView.bounds.size.height)];
                maskView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeBottom) {
            maskView.alpha = 1.0;
            [UIView animateWithDuration:0.25 animations:^{
                [fromView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, fromView.bounds.size.height)];
                maskView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeLeft) {
            maskView.alpha = 1.0;
            [UIView animateWithDuration:0.25 animations:^{
                [fromView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, -fromView.bounds.size.width, 0.0)];
                maskView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else if (self.request.modalStyle.type == LGOModalTypeRight) {
            maskView.alpha = 1.0;
            [UIView animateWithDuration:0.25 animations:^{
                [fromView setTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, fromView.bounds.size.width, 0.0)];
                maskView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
    }
}

@end

@implementation LGOModalController

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.ModalController" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOModalRequest class]]) {
        LGOModalOperation *operation = [LGOModalOperation new];
        operation.request = (LGOModalRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.ModalController" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOModalRequest *request = [LGOModalRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"present";
    request.path = [dictionary[@"path"] isKindOfClass:[NSString class]] ? dictionary[@"path"] : @"";
    request.animated = [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"animated"]).boolValue : YES;
    request.clearWebView = [dictionary[@"clearWebView"] isKindOfClass:[NSNumber class]] ? [dictionary[@"clearWebView"] boolValue] : NO;
    request.clearMask = [dictionary[@"clearMask"] isKindOfClass:[NSNumber class]] ? [dictionary[@"clearMask"] boolValue] : NO;
    request.nonMask = [dictionary[@"nonMask"] isKindOfClass:[NSNumber class]] ? [dictionary[@"nonMask"] boolValue] : NO;
    request.args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    if ([dictionary[@"modalType"] isKindOfClass:[NSNumber class]]) {
        request.modalStyle.type = [dictionary[@"modalType"] integerValue];
        request.modalStyle.size = CGSizeMake([dictionary[@"modalWidth"] isKindOfClass:[NSNumber class]] ? [dictionary[@"modalWidth"] floatValue] : 0.0,
                                             [dictionary[@"modalHeight"] isKindOfClass:[NSNumber class]] ? [dictionary[@"modalHeight"] floatValue] : 0.0);
    }
    request.preloadToken = [dictionary[@"preloadToken"] isKindOfClass:[NSString class]] ? dictionary[@"preloadToken"] : nil;
    return [self buildWithRequest:request];
}

@end
