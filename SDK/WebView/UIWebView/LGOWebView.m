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
@import JavaScriptCore;

@interface LGOWebViewDelegate: NSObject <UIWebViewDelegate>

@property (nonatomic, weak) id<UIWebViewDelegate> delegate;

@end

@interface LGOWebView ()

@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) LGOWebViewDelegate *lgo_delegate;

@end

@implementation LGOWebView

- (void)dealloc
{
    self.delegate = nil;
    self.context.lgo_webView = nil;
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
    self.delegate = self.lgo_delegate;
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (context != nil && context != self.context) {
        context.lgo_webView = self;
        [LGOJavaScriptBridge configureWithJSContext:context];
        self.context = context;
    }
}

- (void)loadRequest:(NSURLRequest *)request {
    [super loadRequest:request];
    self.URL = request.URL;
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [super loadHTMLString:string baseURL:baseURL];
    self.URL = baseURL;
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL {
    [super loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    self.URL = baseURL;
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    if (delegate != self.lgo_delegate) {
        self.lgo_delegate.delegate = delegate;
    }
    [super setDelegate:self.lgo_delegate];
}

- (LGOWebViewDelegate *)lgo_delegate {
    if (_lgo_delegate == nil) {
        _lgo_delegate = [[LGOWebViewDelegate alloc] init];
    }
    return _lgo_delegate;
}

- (NSURL *)URL {
    if (_URL != nil) {
        return _URL;
    }
    else {
        return self.request.URL;
    }
}

@end

@implementation LGOWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    id<UIWebViewDelegate> imp = self.delegate;
    if (imp != nil && [imp respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [imp webViewDidStartLoad:webView];
    }
    if ([webView isKindOfClass:[LGOWebView class]]) {
        [(LGOWebView *)webView configureContext];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id<UIWebViewDelegate> imp = self.delegate;
    if (imp != nil && [imp respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [imp webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    id<UIWebViewDelegate> imp = self.delegate;
    if (imp != nil && [imp respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [imp webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id<UIWebViewDelegate> imp = self.delegate;
    if (imp != nil && [imp respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [imp webViewDidFinishLoad:webView];
    }
}

@end
