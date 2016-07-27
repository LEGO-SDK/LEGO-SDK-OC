//
//  LGOWebViewController+StatusBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController+StatusBar.h"

@implementation LGOWebViewController (StatusBar)

- (void)statusBar_viewWillAppear {
    NSNumber *statusBarHidden = self.initializeContext[@"statusBarHidden"];
    if ([statusBarHidden isKindOfClass:[NSNumber class]]) {
        NSNumber *infoSetting = [[NSBundle mainBundle] infoDictionary][@"UIViewControllerBasedStatusBarAppearance"];
        if ([infoSetting isKindOfClass:[NSNumber class]]) {
            if (![infoSetting boolValue]) {
                [[UIApplication sharedApplication] setStatusBarHidden:[statusBarHidden boolValue] withAnimation:UIStatusBarAnimationSlide];
            }
        }
    }
}

- (void)statusBar_viewWillDisappear {
    NSNumber *statusBarHidden = self.initializeContext[@"statusBarHidden"];
    if ([statusBarHidden isKindOfClass:[NSNumber class]]) {
        NSNumber *infoSetting = [[NSBundle mainBundle] infoDictionary][@"UIViewControllerBasedStatusBarAppearance"];
        if ([infoSetting isKindOfClass:[NSNumber class]]) {
            if (![infoSetting boolValue]) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            }
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    NSString *statusBarStyle = self.initializeContext[@"statusBarStyle"];
    if ([statusBarStyle isKindOfClass:[NSString class]] && [statusBarStyle isEqualToString:@"light"]) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    NSNumber *statusBarHidden = self.initializeContext[@"statusBarHidden"];
    if ([statusBarHidden isKindOfClass:[NSNumber class]] && [statusBarHidden boolValue]) {
        return [statusBarHidden boolValue];
    }
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

@end
