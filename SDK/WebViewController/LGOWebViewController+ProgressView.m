//
//  LGOWebViewController+ProgressView.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+ProgressView.h"
@import WebKit;

@implementation LGOWebViewController (ProgressView)

@dynamic progressView, progressObserverConfigured;

- (void)configureProgressView {
    [self configureProgressViewLayout];
    self.progressView.hidden = YES;
}

- (void)configureProgressViewLayout {
    [self.webView addSubview:self.progressView];
    self.progressView.frame = CGRectMake(0, 0, self.webView.frame.size.width, 1.0);
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)configureProgressObserver {
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        self.progressObserverConfigured = YES;
    }
}

- (void)unconfigureProgressObserver {
    if (self.progressObserverConfigured) {
        if ([self.webView isKindOfClass:[WKWebView class]]) {
            [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        }
    }
}

- (void)progress_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if ([change[@"new"] isKindOfClass:[NSNumber class]]) {
            float estimatedProgress = [change[@"new"] floatValue];
            [self.progressView setProgress:estimatedProgress];
            [self.progressView setHidden:estimatedProgress <= 0.0 || estimatedProgress >= 1.0];
        }
    }
}

@end
