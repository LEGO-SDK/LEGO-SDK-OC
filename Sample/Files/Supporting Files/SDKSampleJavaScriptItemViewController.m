//
//  SDKSampleJavaScriptItemViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWKWebView+DataModel.h"
#import "LGOWKWebView.h"
#import "LGOWebView+DataModel.h"
#import "SDKSampleJavaScriptItemViewController.h"

@implementation SDKSampleJavaScriptItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.itemWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.itemWebView.frame = self.view.bounds;
    [self.view addSubview:self.itemWebView];
    [self configureTests];
}

- (void)configureTests {
    if (self.zipURL != nil) {
        if ([self.itemWebView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.itemWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.zipURL]]];
        } else if ([self.itemWebView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.itemWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.zipURL]]];
        }
    } else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:self.file ofType:@"html"];
//        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if ([self.itemWebView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.itemWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
        } else if ([self.itemWebView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.itemWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
        }
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootViewController) {
            rootViewController.accessibilityLabel = @"AppFrame";
        }
        [self configureTestCases];
    }
}

- (void)configureTestCases {
    if ([self.file isEqualToString:@"Native.DataModel"]) {
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(testDataModel)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)testDataModel {
    if ([self.itemWebView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.itemWebView updateDataModel:@"date" dataValue:[[NSDate new] description]];
    } else if ([self.itemWebView isKindOfClass:[WKWebView class]]) {
        [(WKWebView *)self.itemWebView updateDataModel:@"date" dataValue:[[NSDate new] description]];
    }
}

@end
