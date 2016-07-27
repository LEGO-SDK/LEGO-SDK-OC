//
//  LGOWKWebView.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface LGOWKWebView : WKWebView

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
