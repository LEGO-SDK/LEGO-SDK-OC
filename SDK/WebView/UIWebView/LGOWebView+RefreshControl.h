//
//  LGOWebView+RefreshControl.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebView.h"

@interface LGOWebView (RefreshControl)

- (void)requestRefreshControl;

- (void)configureRefreshControl:(NSObject *)target;

- (void)endRefreshing;

@end
