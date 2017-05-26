//
//  LGOBaseNavigationController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGOBaseNavigationController : UINavigationController

@property (nonatomic, strong) CALayer *defaultBackgroundLayer;
@property (nonatomic, strong) IBInspectable UIColor *defaultTintColor;
@property (nonatomic, assign) UIStatusBarStyle defaultStatusBarStyle;

- (void)reloadSetting;

@end
