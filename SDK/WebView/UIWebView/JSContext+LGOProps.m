//
//  JSContext+LGOProps.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "JSContext+LGOProps.h"
#import <objc/runtime.h>

static int kJSWebViewIdentifierKey;

@implementation JSContext (LGOProps)

- (void)setLgo_webView:(LGOWebView *)lgo_webView {
    objc_setAssociatedObject(self, &kJSWebViewIdentifierKey, lgo_webView, OBJC_ASSOCIATION_ASSIGN);
}

- (LGOWebView *)lgo_webView {
    return objc_getAssociatedObject(self, &kJSWebViewIdentifierKey);
}

@end
