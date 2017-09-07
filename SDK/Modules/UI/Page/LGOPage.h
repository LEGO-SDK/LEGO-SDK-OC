//
//  LGOPage.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOCore.h"

@interface LGOPageRequest : LGORequest

@property (nonatomic, readonly) NSString *urlPattern;

@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) UIColor *backgroundColor;

@property (nonatomic, readonly) BOOL statusBarHidden;

@property (nonatomic, readonly) UIStatusBarStyle statusBarStyle;

@property (nonatomic, readonly) BOOL navigationBarHidden;

@property (nonatomic, readonly) BOOL navigationBarSeparatorHidden;

@property (nonatomic, readonly) UIColor *navigationBarBackgroundColor;

@property (nonatomic, readonly) UIColor *navigationBarTintColor;

@property (nonatomic, readonly) BOOL fullScreenContent;

@property (nonatomic, readonly) BOOL allowBounce;

@property (nonatomic, readonly) BOOL alwaysBounce;

@property (nonatomic, readonly) BOOL showsIndicator;

@end

@interface LGOPage : LGOModule

@end
