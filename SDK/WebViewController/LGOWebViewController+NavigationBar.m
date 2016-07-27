//
//  LGOWebViewController+NavigationBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+NavigationBar.h"

@implementation LGOWebViewController (NavigationBar)

- (void)navigationBar_viewWillAppear {
    NSNumber *navigationBarHidden = self.initializeContext[@"navigationBarHidden"];
    if ([navigationBarHidden isKindOfClass:[NSNumber class]]) {
        [self.navigationController setNavigationBarHidden:[navigationBarHidden boolValue] animated:YES];
    }
}

- (void)navigationBar_viewDidAppear {
    NSNumber *navigationBarHidden = self.initializeContext[@"navigationBarHidden"];
    if ([navigationBarHidden isKindOfClass:[NSNumber class]]) {
        [self.navigationController setNavigationBarHidden:[navigationBarHidden boolValue] animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController setNavigationBarHidden:[navigationBarHidden boolValue] animated:NO];
        });
    }
}

- (void)navigationBar_viewDidDisappear {
    NSNumber *navigationBarHidden = self.initializeContext[@"navigationBarHidden"];
    if ([navigationBarHidden isKindOfClass:[NSNumber class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

@end
