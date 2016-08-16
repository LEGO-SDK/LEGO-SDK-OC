//
//  LGOProgressView.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "LGOProgressView.h"

@interface LGOProgressView ()

@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) NSTimer *hiddenTimer;

@end

@implementation LGOProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        _progressView = [[UIProgressView alloc] init];
    }
    return self;
}

- (void)setProgress:(double)progress {
    [self.hiddenTimer invalidate];
    [self.progressView setAlpha:1.0];
    [self.progressView setProgress:progress animated:YES];
    if (progress == 1.0) {
        self.hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:0.80
                                                            target:self
                                                          selector:@selector(hidesWithDelay)
                                                          userInfo:nil
                                                           repeats:NO];
    }
}

- (void)hidesWithDelay {
    [UIView animateWithDuration:0.30
                     animations:^{
                       [self.progressView setAlpha:0.0];
                     }
                     completion:nil];
}

@end

@interface WKWebView (LGOProgressView)

@property(nonatomic, strong) LGOProgressView *lgo_progressView;

@end

@implementation WKWebView (LGOProgressView)

+ (void)load {
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          Class class = [WKWebView class];
          SEL originalSelector = @selector(willMoveToSuperview:);
          SEL swizzledSelector = @selector(lgo_progressViewWillMoveToSuperview:);
          Method originalMethod = class_getInstanceMethod(class, originalSelector);
          Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
          BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod),
                                              method_getTypeEncoding(swizzledMethod));

          if (didAddMethod) {
              class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod),
                                  method_getTypeEncoding(originalMethod));
          } else {
              method_exchangeImplementations(originalMethod, swizzledMethod);
          }
        });
    }
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          Class class = [WKWebView class];
          SEL originalSelector = @selector(didChangeValueForKey:);
          SEL swizzledSelector = @selector(lgo_progressViewDidChangeValueForKey:);
          Method originalMethod = class_getInstanceMethod(class, originalSelector);
          Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
          BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod),
                                              method_getTypeEncoding(swizzledMethod));

          if (didAddMethod) {
              class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod),
                                  method_getTypeEncoding(originalMethod));
          } else {
              method_exchangeImplementations(originalMethod, swizzledMethod);
          }
        });
    }
}

- (void)lgo_progressViewWillMoveToSuperview:(UIView *)newSuperview {
    [self lgo_progressViewWillMoveToSuperview:newSuperview];
    if (self.lgo_progressView == nil) {
        self.lgo_progressView = [[LGOProgressView alloc] init];
    }
    [self addSubview:self.lgo_progressView.progressView];
    self.lgo_progressView.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lgo_progressView.progressView.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
}

- (void)lgo_progressViewDidChangeValueForKey:(NSString *)key {
    [self lgo_progressViewDidChangeValueForKey:key];
    if ([key isEqualToString:@"estimatedProgress"] && self.lgo_progressView != nil) {
        [self.lgo_progressView setProgress:self.estimatedProgress];
    }
}

static int kProgressViewIdentifierKey;

- (void)setLgo_progressView:(LGOProgressView *)lgo_progressView {
    objc_setAssociatedObject(self, &kProgressViewIdentifierKey, lgo_progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LGOProgressView *)lgo_progressView {
    return objc_getAssociatedObject(self, &kProgressViewIdentifierKey);
}

@end
