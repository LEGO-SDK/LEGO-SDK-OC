//
//  LGOIndicatorView.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "LGOCore.h"
#import "LGOIndicatorView.h"

@interface LGOIndicatorViewRequest : LGORequest

@property(nonatomic, assign) UIEdgeInsets insets;
@property(nonatomic, assign) BOOL hidden;

@end

@implementation LGOIndicatorViewRequest

@end

@interface LGOIndicatorViewOperation : LGORequestable

@property(nonatomic, strong) LGOIndicatorViewRequest *request;

@end

@implementation LGOIndicatorViewOperation

- (LGOResponse *)requestSynchronize {
    UIView *webView = [self.request.context requestWebView];
    if ([webView isKindOfClass:[UIWebView class]]) {
        ((UIWebView *)webView).scrollView.showsHorizontalScrollIndicator = !self.request.hidden;
        ((UIWebView *)webView).scrollView.showsVerticalScrollIndicator = !self.request.hidden;
        ((UIWebView *)webView).scrollView.scrollIndicatorInsets = self.request.insets;
        return [[LGOResponse new] accept:nil];
    } else if ([webView isKindOfClass:[WKWebView class]]) {
        ((WKWebView *)webView).scrollView.showsHorizontalScrollIndicator = !self.request.hidden;
        ((WKWebView *)webView).scrollView.showsVerticalScrollIndicator = !self.request.hidden;
        ((WKWebView *)webView).scrollView.scrollIndicatorInsets = self.request.insets;
        return [[LGOResponse new] accept:nil];
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.Bounce"
                                                             code:-3
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"WebView not found."
                                                         }]];
    }
}

@end

@implementation LGOIndicatorView

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.IndicatorView" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOIndicatorViewRequest class]]) {
        LGOIndicatorViewOperation *operation = [LGOIndicatorViewOperation new];
        operation.request = (LGOIndicatorViewRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.IndicatorView" code:-1 reason:@"Type error."];
}

- (CGFloat)pickValue:(NSNumber *)num {
    if (num == nil) {
        return 0.0;
    }
    return num.floatValue;
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOIndicatorViewRequest *request = [LGOIndicatorViewRequest new];
    request.context = context;
    request.hidden =
        [dictionary[@"hidden"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"hidden"]).boolValue : NO;
    NSDictionary<NSString *, NSNumber *> *insetsValue =
        [dictionary[@"insets"] isKindOfClass:[NSDictionary<NSString *, NSNumber *> class]] ? dictionary[@"insets"]
                                                                                           : @{};
    request.insets = UIEdgeInsetsMake([self pickValue:insetsValue[@"top"]], [self pickValue:insetsValue[@"left"]],
                                      [self pickValue:insetsValue[@"bottom"]], [self pickValue:insetsValue[@"right"]]);
    return [self buildWithRequest:request];
}

@end
