//
//  UIViewController+LGOStatusBar.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LGOStatusBar)

@property (nonatomic, assign) UIStatusBarStyle lgo_statusBarStyle;
@property (nonatomic, assign) BOOL lgo_statusBarHidden;

- (void)lgo_setNeedsStatusBarAppearanceUpdate:(BOOL)animated;

@end
