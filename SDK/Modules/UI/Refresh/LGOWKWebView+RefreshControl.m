//
//  LGOWKWebView+RefreshControl.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWKWebView+RefreshControl.h"
#import <objc/runtime.h>

#pragma GCC diagnostic ignored "-Wundeclared-selector"

static int kRefreshControlIdentifierKey;

@implementation WKWebView (RefreshControl)

- (void)requestRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
}

- (void)configureRefreshControl:(NSObject *)target; {
    [self requestRefreshControl];
    if (self.refreshControl != nil) {
        if ([target respondsToSelector:@selector(handleRefreshControlTrigger)]) {
            [self.refreshControl addTarget:target action:@selector(handleRefreshControlTrigger) forControlEvents:UIControlEventValueChanged];
        }
        [self.scrollView addSubview:self.refreshControl];
    }
}

- (void)endRefreshing {
    if (self.refreshControl != nil) {
        [self.refreshControl endRefreshing];
    }
}

- (UIRefreshControl *)refreshControl {
    return objc_getAssociatedObject(self, &kRefreshControlIdentifierKey);
}

- (void)setRefreshControl:(UIRefreshControl *)refreshControl {
    objc_setAssociatedObject(self, &kRefreshControlIdentifierKey, refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
