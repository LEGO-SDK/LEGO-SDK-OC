//
//  LGOWKWebView.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOJavaScriptUserContentController.h"
#import "LGONotification.h"
#import "LGOWKWebView.h"

@implementation LGOWKWebView

- (void)dealloc {
    self.navigationDelegate = nil;
    self.UIDelegate = nil;
    [LGONotification LGONotificationGC];
}

+ (WKWebViewConfiguration *)bridge_configuration {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    LGOJavaScriptUserContentController *userContentController = [[LGOJavaScriptUserContentController alloc] init];
    configuration.userContentController = userContentController;
    configuration.allowsInlineMediaPlayback = YES;
    configuration.requiresUserActionForMediaPlayback = NO;
    return configuration;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame configuration:[LGOWKWebView bridge_configuration]];
    if (self) {
        [(LGOJavaScriptUserContentController *)self.configuration.userContentController setWebView:self];
        _dataModel = [NSMutableDictionary new];
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
    }
    return self;
}

@end
