//
//  LGOWebViewController+ProgressView.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebViewController.h"

@interface LGOWebViewController (ProgressView)

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL progressObserverConfigured;

- (void)configureProgressView;
- (void)configureProgressViewLayout;
- (void)configureProgressObserver;
- (void)unconfigureProgressObserver;
- (void)progress_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context;

@end
