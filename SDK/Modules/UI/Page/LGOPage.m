//
//  LGOPage.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOPage.h"
#import "LGOPageStore.h"

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

@property (nonatomic, assign) BOOL showsIndicator;

@end

@implementation LGOPageRequest

@end

@interface LGOPageOperation : LGORequestable

@property (nonatomic, strong) NSArray<LGOPageRequest *> *requests;

@end

@implementation LGOPageOperation

- (LGOResponse *)requestSynchronize {
    for (LGOPageRequest *request in self.requests) {
        [[LGOPageStore sharedStore] addItem:request];
    }
    return [[LGOResponse new] accept:nil];
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    callbackBlock([self requestSynchronize]);
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
            request.urlPattern = [dictionary[@"urlPattern"] isKindOfClass:[NSString class]] ? dictionary[@"urlPattern"] : nil;
            request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : nil;
            request.backgroundColor = [dictionary[@"backgroundColor"] isKindOfClass:[NSString class]] ? [LGOPage colorWithHex:dictionary[@"backgroundColor"]] : nil;
            request.statusBarHidden = [dictionary[@"statusBarHidden"] isKindOfClass:[NSNumber class]] ? [dictionary[@"statusBarHidden"] boolValue] : NO;
            request.statusBarStyle = [dictionary[@"statusBarStyle"] isKindOfClass:[NSString class]] ? ([dictionary[@"statusBarStyle"] isEqualToString:@"light"] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) : UIStatusBarStyleDefault;
            request.navigationBarHidden = [dictionary[@"navigationBarHidden"] isKindOfClass:[NSNumber class]] ? [dictionary[@"navigationBarHidden"] boolValue] : NO;
            request.navigationBarSeparatorHidden = [dictionary[@"navigationBarSeparatorHidden"] isKindOfClass:[NSNumber class]] ? [dictionary[@"navigationBarSeparatorHidden"] boolValue] : NO;
            request.navigationBarBackgroundColor = [dictionary[@"navigationBarBackgroundColor"] isKindOfClass:[NSString class]] ? [LGOPage colorWithHex:dictionary[@"navigationBarBackgroundColor"]] : nil;
            request.navigationBarTintColor = [dictionary[@"navigationBarTintColor"] isKindOfClass:[NSString class]] ? [LGOPage colorWithHex:dictionary[@"navigationBarTintColor"]] : nil;
            request.fullScreenContent = [dictionary[@"fullScreenContent"] isKindOfClass:[NSNumber class]] ? [dictionary[@"fullScreenContent"] boolValue] : NO;
            request.allowBounce = [dictionary[@"allowBounce"] isKindOfClass:[NSNumber class]] ? [dictionary[@"allowBounce"] boolValue] : YES;
            request.showsIndicator = [dictionary[@"showsIndicator"] isKindOfClass:[NSNumber class]] ? [dictionary[@"showsIndicator"] boolValue] : YES;
            [requests addObject:request];
        }
    }
    LGOPageOperation *operation = [LGOPageOperation new];
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
