//
//  UIWebView+LGOAutoInject.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (LGOAutoInject)

@property (nonatomic, strong) JSContext *lgo_context;

@end
