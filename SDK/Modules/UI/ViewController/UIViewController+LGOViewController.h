//
//  UIViewController+LGOViewController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LGOViewController)

@property (nonatomic, strong) UIView *lgo_webView;

- (void)lgo_openWebViewWithRequest:(NSURLRequest *)request args:(NSDictionary *)args;

- (void)lgo_dismiss;

@end
