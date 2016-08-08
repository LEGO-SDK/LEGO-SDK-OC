//
//  SDKSampleJavaScriptItemViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SDKSampleJavaScriptItemViewController.h"
@import WebKit;

@implementation SDKSampleJavaScriptItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.file ofType:@"html"];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.webView loadHTMLString:content baseURL:[NSURL URLWithString:@"http://127.0.0.1/"]];
    }
    else if ([self.webView isKindOfClass:[WKWebView class]]) {
        [(WKWebView *)self.webView loadHTMLString:content baseURL:[NSURL URLWithString:@"http://127.0.0.1/"]];
    }
    
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(rootViewController){
        rootViewController.accessibilityLabel = @"AppFrame";
    }
}

@end
