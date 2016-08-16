//
//  JSContext+LGOProps.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "JSContext+LGOProps.h"

static int kJSWebViewIdentifierKey;

@implementation JSContext (LGOProps)

- (void)setLgo_webView:(UIWebView *)lgo_webView {
    objc_setAssociatedObject(self, &kJSWebViewIdentifierKey, lgo_webView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIWebView *)lgo_webView {
    return objc_getAssociatedObject(self, &kJSWebViewIdentifierKey);
}

@end
