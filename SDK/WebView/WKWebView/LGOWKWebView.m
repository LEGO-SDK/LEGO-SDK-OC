//
//  LGOWKWebView.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOJavaScriptUserContentController.h"
#import "LGOWKWebView.h"


@implementation LGOWKWebView

static NSInteger webViewPoolSize;
static NSArray *webViewPool;
static void (^_afterCreate)(LGOWKWebView *webView);

+ (void)load {
    [self setPoolSize:2];
}

+ (void)setPoolSize:(NSInteger)size {
    webViewPoolSize = size;
}

+ (WKWebView *)requestWebViewFromPool {
    if (webViewPool.count > 0) {
        NSMutableArray *mutablePool = [webViewPool mutableCopy];
        LGOWKWebView *webView = [mutablePool firstObject];
        [mutablePool removeObjectAtIndex:0];
        webViewPool = [mutablePool copy];
        [self refillPool];
        return webView;
    }
    else {
        [self refillPool];
    }
    return nil;
}

+ (void)refillPool {
    if (webViewPool.count < webViewPoolSize) {
        NSMutableArray *mutablePool = [webViewPool mutableCopy] ?: [NSMutableArray array];
        for (NSInteger i = 0; i < webViewPoolSize - webViewPool.count; i++) {
            [mutablePool addObject:[[LGOWKWebView alloc] initWithFrame:CGRectZero]];
        }
        webViewPool = [mutablePool copy];
    }
}

+ (void)setAfterCreate:(void (^)(LGOWKWebView *))afterCreate {
    if (_afterCreate != afterCreate) {
        _afterCreate = afterCreate;
    }
}

+ (void (^)(LGOWKWebView *))afterCreate {
    return _afterCreate;
}

- (void)dealloc {
    self.navigationDelegate = nil;
    self.UIDelegate = nil;
}

+ (WKWebViewConfiguration *)bridge_configuration {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    LGOJavaScriptUserContentController *userContentController = [[LGOJavaScriptUserContentController alloc] init];
    configuration.userContentController = userContentController;
    configuration.allowsInlineMediaPlayback = YES;
    if ([configuration respondsToSelector:@selector(requiresUserActionForMediaPlayback)]) {
        configuration.requiresUserActionForMediaPlayback = NO;
    }
    return configuration;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame configuration:[LGOWKWebView bridge_configuration]];
    if (self) {
        [(LGOJavaScriptUserContentController *)self.configuration.userContentController setWebView:self];
        _dataModel = [NSMutableDictionary new];
        self.scrollView.alwaysBounceHorizontal = NO;
        self.scrollView.alwaysBounceVertical = NO;
        if (LGOWKWebView.afterCreate) {
            LGOWKWebView.afterCreate(self);
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration {
    self = [super
        initWithFrame:frame
        configuration:[configuration.userContentController isKindOfClass:[LGOJavaScriptUserContentController class]]
                          ? configuration
                          : [LGOWKWebView bridge_configuration]];
    if (self) {
        [(LGOJavaScriptUserContentController *)self.configuration.userContentController setWebView:self];
        _dataModel = [NSMutableDictionary new];
        self.scrollView.alwaysBounceHorizontal = NO;
        self.scrollView.alwaysBounceVertical = NO;
        if (LGOWKWebView.afterCreate) {
            LGOWKWebView.afterCreate(self);
        }
    }
    return self;
}

@end
