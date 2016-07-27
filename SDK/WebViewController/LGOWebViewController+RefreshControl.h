//
//  LGOWebViewController+RefreshControl.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController.h"

@interface LGOWebViewController (RefreshControl)

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (void)requestRefreshControl;

- (void)configureRefreshControl;

- (void)handleRefreshControlTrigger;

@end
