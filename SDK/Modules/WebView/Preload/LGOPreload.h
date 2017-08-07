//
//  LGOPreload.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/8/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOWKWebView.h"

@interface LGOPreload : LGOModule

- (LGOWKWebView *)fetchWebView:(NSString *)token;

@end
