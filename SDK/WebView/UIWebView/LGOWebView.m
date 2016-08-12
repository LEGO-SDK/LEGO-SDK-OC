//
//  LGOWebView.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebView.h"
#import "LGOJavaScriptBridge.h"
#import "JSContext+LGOProps.h"
#import "LGONotification.h"
@import JavaScriptCore;

@interface LGOWebView ()

@property (nonatomic, strong) JSContext *context;

@end

@implementation LGOWebView

- (void)dealloc
{
    self.delegate = nil;
    self.context.lgo_webView = nil;
    [LGONotification LGONotificationGC];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureContext];
        self.keyboardDisplayRequiresUserAction = NO;
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackRequiresUserAction = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configureContext];
        self.keyboardDisplayRequiresUserAction = NO;
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackRequiresUserAction = NO;
    }
    return self;
}

- (void)configureContext {
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (context != nil && context != self.context) {
        context.lgo_webView = self;
        [LGOJavaScriptBridge configureWithJSContext:context];
        self.context = context;
    }
}

@end