//
//  LGOWKWebView.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface LGOWKWebView : WKWebView

+ (void)setPoolSize:(NSInteger)size;

+ (WKWebView *)requestWebViewFromPool;

@property(nonatomic, strong) UIRefreshControl *refreshControl;

@property(nonatomic, strong) NSMutableDictionary *dataModel;

@property (class, nonatomic, copy) void (^afterCreate)(LGOWKWebView *webView);
@end
