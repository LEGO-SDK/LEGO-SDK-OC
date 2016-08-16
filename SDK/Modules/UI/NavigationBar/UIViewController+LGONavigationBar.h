//
//  UIViewController+LGONavigationBar.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LGONavigationBar)

@property(nonatomic, assign) BOOL lgo_navigationBarHidden;

- (void)lgo_setNeedsNavigationBarAppearanceUpdate:(BOOL)animated;

@end
