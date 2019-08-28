//
//  SDKSampleJavaScriptItemViewController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "LGOBaseViewController.h"


@interface SDKSampleJavaScriptItemViewController : LGOBaseViewController

@property(nonatomic, strong) WKWebView *itemWebView;

@property(nonatomic, copy) NSString *file;
@property(nonatomic, copy) NSString *zipURL;

@end
