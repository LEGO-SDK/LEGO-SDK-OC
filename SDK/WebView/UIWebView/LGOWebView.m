//
//  LGOWebView.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "JSContext+LGOProps.h"
#import "LGOJavaScriptBridge.h"
#import "LGOWebView.h"
@import JavaScriptCore;

@interface LGOWebView ()

@property(nonatomic, strong) JSContext *context;

@end

@implementation LGOWebView

- (void)dealloc {
    self.delegate = nil;
    self.context.lgo_webView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureContext];
        self.keyboardDisplayRequiresUserAction = NO;
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackRequiresUserAction = NO;
        self.scrollView.alwaysBounceHorizontal = NO;
        self.scrollView.alwaysBounceVertical = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self configureContext];
        self.keyboardDisplayRequiresUserAction = NO;
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackRequiresUserAction = NO;
        self.scrollView.alwaysBounceHorizontal = NO;
        self.scrollView.alwaysBounceVertical = NO;
    }
    return self;
}

- (void)configureContext {
    if ([self respondsToSelector:NSSelectorFromString(@"lgo_context")]) {
        return;
    }
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (context != nil && context != self.context) {
        context.lgo_webView = self;
        [LGOJavaScriptBridge configureWithJSContext:context];
        self.context = context;
    }
}

@end
