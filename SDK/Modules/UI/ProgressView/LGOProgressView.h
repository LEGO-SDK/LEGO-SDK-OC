//
//  LGOProgressView.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGOProgressView : NSObject
@property (nonatomic, copy, class) NSString *customProgressViewClassName;
@property (nonatomic, copy, class) void (^progressDidChangeCallback)(double progress, UIView *webView);
@end
