//
//  LGOPage.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOPage.h"
#import "LGOPageStore.h"
#import "LGOBaseViewController.h"
#import <WebKit/WebKit.h>

@interface LGOPageRequest ()

@property (nonatomic, copy) NSString *urlPattern;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, assign) BOOL navigationBarHidden;

@property (nonatomic, assign) BOOL navigationBarSeparatorHidden;

@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

@property (nonatomic, strong) UIColor *navigationBarTintColor;

@property (nonatomic, assign) BOOL fullScreenContent;

@property (nonatomic, assign) BOOL allowBounce;

@property (nonatomic, assign) BOOL alwaysBounce;

@property (nonatomic, assign) BOOL showsIndicator;

@end

@implementation LGOPageRequest

@end

@interface LGOPageOperation : LGORequestable

@property (nonatomic, strong) LGORequestContext *context;

@property (nonatomic, strong) NSArray<LGOPageRequest *> *requests;

@end

@implementation LGOPageOperation

- (LGOResponse *)requestSynchronize {
    for (LGOPageRequest *request in self.requests) {
        [[LGOPageStore sharedStore] addItem:request];
        if (request.urlPattern == nil) {
            UIViewController *viewController = [self requestViewController];
            if ([viewController isKindOfClass:[LGOBaseViewController class]]) {
                [(LGOBaseViewController *)viewController reloadSetting:request];
            }
        }
    }
    UIViewController *viewController = [self requestViewController];
    if ([viewController isKindOfClass:[LGOBaseViewController class]]) {
        [(LGOBaseViewController *)viewController reloadSetting:nil];
    }
    return [[LGOResponse new] accept:nil];
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    callbackBlock([self requestSynchronize]);
}

- (UIViewController *)requestViewController {
    UIView *view =
    [self.context.sender isKindOfClass:[UIView class]] ? (UIView *)self.context.sender : nil;
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

@end

@implementation LGOPage

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.Page" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOPageRequest class]]) {
        LGOPageOperation *operation = [LGOPageOperation new];
        operation.requests = @[(id)request];
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.Page" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSURL *currentURL = nil;
    UIView *webView = context.requestWebView;
    if (webView != nil && [webView isKindOfClass:[UIWebView class]]) {
        currentURL = ((UIWebView *)webView).request.URL;
    }
    if (webView != nil && [webView isKindOfClass:[WKWebView class]]) {
        currentURL = ((WKWebView *)webView).URL;
    }
    NSMutableArray *requests = [NSMutableArray array];
    NSMutableArray *items = [NSMutableArray array];
    if ([dictionary[@"items"] isKindOfClass:[NSArray class]]) {
        [items addObjectsFromArray:dictionary[@"items"]];
    }
    else {
        [items addObject:dictionary];
    }
    for (NSDictionary *item in items) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            LGOPageRequest *request = [LGOPageRequest new];
            request.urlPattern = [item[@"urlPattern"] isKindOfClass:[NSString class]] ? item[@"urlPattern"] : nil;
            request.title = [item[@"title"] isKindOfClass:[NSString class]] ? item[@"title"] : nil;
            request.backgroundColor = [item[@"backgroundColor"] isKindOfClass:[NSString class]] ? [LGOPage colorWithHex:item[@"backgroundColor"]] : [UIColor whiteColor];
            request.statusBarHidden = [item[@"statusBarHidden"] isKindOfClass:[NSNumber class]] ? [item[@"statusBarHidden"] boolValue] : NO;
            request.statusBarStyle = [item[@"statusBarStyle"] isKindOfClass:[NSString class]] ? ([item[@"statusBarStyle"] isEqualToString:@"light"] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) : UIStatusBarStyleDefault;
            request.navigationBarHidden = [item[@"navigationBarHidden"] isKindOfClass:[NSNumber class]] ? [item[@"navigationBarHidden"] boolValue] : NO;
            request.navigationBarSeparatorHidden = [item[@"navigationBarSeparatorHidden"] isKindOfClass:[NSNumber class]] ? [item[@"navigationBarSeparatorHidden"] boolValue] : NO;
            request.navigationBarBackgroundColor = [item[@"navigationBarBackgroundColor"] isKindOfClass:[NSString class]] ? [LGOPage colorWithHex:item[@"navigationBarBackgroundColor"]] : nil;
            request.navigationBarTintColor = [item[@"navigationBarTintColor"] isKindOfClass:[NSString class]] ? [LGOPage colorWithHex:item[@"navigationBarTintColor"]] : nil;
            request.fullScreenContent = [item[@"fullScreenContent"] isKindOfClass:[NSNumber class]] ? [item[@"fullScreenContent"] boolValue] : NO;
            request.allowBounce = [item[@"allowBounce"] isKindOfClass:[NSNumber class]] ? [item[@"allowBounce"] boolValue] : YES;
            request.alwaysBounce = [item[@"alwaysBounce"] isKindOfClass:[NSNumber class]] ? [item[@"alwaysBounce"] boolValue] : NO;
            request.showsIndicator = [item[@"showsIndicator"] isKindOfClass:[NSNumber class]] ? [item[@"showsIndicator"] boolValue] : YES;
            if ([NSURL URLWithString:request.urlPattern].host.length > 0 ||
                [[NSURL URLWithString:request.urlPattern].scheme isEqualToString:@"file"] ||
                request.urlPattern == nil) {
                [requests addObject:request];
            }
        }
    }
    LGOPageOperation *operation = [LGOPageOperation new];
    operation.context = context;
    operation.requests = [requests copy];
    return operation;
}

#pragma mark - Helpers

+ (UIColor *)colorWithHex:(NSString *)hex {
    NSString *colorHex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    colorHex = [colorHex uppercaseString];
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    switch ([colorHex length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorHex start: 0 length: 1];
            green = [self colorComponentFrom:colorHex start: 1 length: 1];
            blue  = [self colorComponentFrom:colorHex start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorHex start: 0 length: 1];
            red   = [self colorComponentFrom:colorHex start: 1 length: 1];
            green = [self colorComponentFrom:colorHex start: 2 length: 1];
            blue  = [self colorComponentFrom:colorHex start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorHex start: 0 length: 2];
            green = [self colorComponentFrom:colorHex start: 2 length: 2];
            blue  = [self colorComponentFrom:colorHex start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorHex start: 0 length: 2];
            red   = [self colorComponentFrom:colorHex start: 2 length: 2];
            green = [self colorComponentFrom:colorHex start: 4 length: 2];
            blue  = [self colorComponentFrom:colorHex start: 6 length: 2];
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


@end
