//
//  LGOViewController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOPage.h"

@interface LGOBaseViewController : UIViewController

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, readonly) LGOPageRequest *setting;
@property (nonatomic, readonly) UIView *webView;

@end
