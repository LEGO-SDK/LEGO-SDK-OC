//
//  LGOBaseNavigationController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOBaseNavigationController.h"
#import "LGOBaseViewController.h"

@interface LGOBaseNavigationController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIViewController *popingViewController;
@property (nonatomic, assign) BOOL barHidden;
@property (nonatomic, assign) BOOL barWillAppear;
@property (nonatomic, strong) CALayer *barTintLayer;

@end

@implementation LGOBaseNavigationController

- (void)dealloc {
    [self.navigationBar removeObserver:self forKeyPath:@"bounds"];
    [self.navigationBar removeObserver:self forKeyPath:@"alpha"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.navigationBar.translucent = YES;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar.subviews.firstObject.layer addSublayer:self.barTintLayer];
    [self.navigationBar addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    [self.navigationBar addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(onInteractivePopGestureRecognizer:)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.navigationBar && [keyPath isEqualToString:@"bounds"]) {
        self.barTintLayer.frame = self.barTintLayer.superlayer.bounds;
        for (CALayer *sublayer in self.barTintLayer.sublayers) {
            sublayer.frame = self.barTintLayer.bounds;
        }
    }
    if (object == self.navigationBar && [keyPath isEqualToString:@"alpha"]) {
        if (self.navigationBar.alpha > 0.0 && self.barHidden && !self.barWillAppear) {
            self.navigationBar.alpha = 0.0;
        }
    }
}

- (void)onInteractivePopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat progress = [sender locationInView:nil].x / [UIScreen mainScreen].bounds.size.width;
        [CATransaction setDisableActions:YES];
        if (self.barTintLayer.sublayers.count >= 2) {
            self.barTintLayer.sublayers[self.barTintLayer.sublayers.count - 1].opacity = 1.0 - progress;
            self.barTintLayer.sublayers[self.barTintLayer.sublayers.count - 2].opacity = progress;
        }
        if (self.barWillAppear) {
            self.navigationBar.alpha = MAX(self.navigationBar.alpha, progress);
        }
        [CATransaction setDisableActions:NO];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        if ([sender velocityInView:nil].x < 500 && [sender translationInView:nil].x < [UIScreen mainScreen].bounds.size.width / 2.0) {
            if (self.popingViewController != nil) {
                [self navigationController:self willShowViewController:self.popingViewController animated:YES];
                self.barTintLayer.sublayers.lastObject.opacity = 1.0;
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateChanged ||
        self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    }
    else {
        [self resetBarTintLayer];
    }
    if ([viewController isKindOfClass:[LGOBaseViewController class]]) {
        if (self.navigationBar.alpha <= 0.0) {
            self.barWillAppear = ![(LGOBaseViewController *)viewController setting].navigationBarHidden;
        }
        if ([(LGOBaseViewController *)viewController setting].navigationBarTintColor != nil) {
            self.navigationBar.tintColor = [(LGOBaseViewController *)viewController setting].navigationBarTintColor;
            self.navigationBar.titleTextAttributes = @{
                                                       NSForegroundColorAttributeName: [(LGOBaseViewController *)viewController setting].navigationBarTintColor,
                                                       };
        }
        else if (self.defaultTintColor != nil) {
            self.navigationBar.tintColor = self.defaultTintColor;
            self.navigationBar.titleTextAttributes = @{
                                                       NSForegroundColorAttributeName: self.defaultTintColor,
                                                       };
        }
    }
    else {
        if (self.navigationBar.alpha <= 0.0) {
            self.barWillAppear = YES;
        }
        if (self.defaultTintColor != nil) {
            self.navigationBar.tintColor = self.defaultTintColor;
            self.navigationBar.titleTextAttributes = @{
                                                       NSForegroundColorAttributeName: self.defaultTintColor,
                                                       };
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self resetBarTintLayer];
    if ([viewController isKindOfClass:[LGOBaseViewController class]]) {
        self.navigationBar.alpha = [(LGOBaseViewController *)viewController setting].navigationBarHidden ? 0.0 : 1.0;
        self.barHidden = [(LGOBaseViewController *)viewController setting].navigationBarHidden;
        if ([(LGOBaseViewController *)viewController setting].navigationBarTintColor != nil) {
            self.navigationBar.tintColor = [(LGOBaseViewController *)viewController setting].navigationBarTintColor;
            self.navigationBar.titleTextAttributes = @{
                                                       NSForegroundColorAttributeName: [(LGOBaseViewController *)viewController setting].navigationBarTintColor,
                                                       };
        }
        else if (self.defaultTintColor != nil) {
            self.navigationBar.tintColor = self.defaultTintColor;
            self.navigationBar.titleTextAttributes = @{
                                                       NSForegroundColorAttributeName: self.defaultTintColor,
                                                       };
        }
    }
    else {
        self.navigationBar.alpha = 1.0;
        if (self.defaultTintColor != nil) {
            self.navigationBar.tintColor = self.defaultTintColor;
            self.navigationBar.titleTextAttributes = @{
                                                       NSForegroundColorAttributeName: self.defaultTintColor,
                                                       };
        }
    }
    self.popingViewController = self.viewControllers.lastObject;
}

- (void)resetBarTintLayer {
    [self.barTintLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    NSInteger atIndex = 0;
    for (UIViewController *childViewController in self.childViewControllers) {
        CALayer *layer = self.defaultBackgroundLayer ? self.defaultBackgroundLayer : [CALayer layer];
        if (self.defaultBackgroundLayer == nil) {
            layer.backgroundColor = self.navigationBar.barTintColor.CGColor;
        }
        if ([childViewController isKindOfClass:[LGOBaseViewController class]]) {
            if ([(LGOBaseViewController *)childViewController setting]) {
                if ([[(LGOBaseViewController *)childViewController setting] navigationBarHidden]) {
                    layer.backgroundColor = [UIColor clearColor].CGColor;
                    if (atIndex == self.childViewControllers.count - 1) {
                        self.navigationBar.alpha = 0.0;
                    }
                }
                else {
                    if ([[(LGOBaseViewController *)childViewController setting] navigationBarBackgroundColor] != nil) {
                        layer.backgroundColor = [[(LGOBaseViewController *)childViewController setting] navigationBarBackgroundColor].CGColor;
                    }
                }
                [self.navigationBar setShadowImage:([[(LGOBaseViewController *)childViewController setting] navigationBarSeparatorHidden] ? [UIImage new] : nil)];
            }
        }
        layer.frame = self.barTintLayer.bounds;
        layer.opacity = atIndex < self.childViewControllers.count - 1 ? 0.0 : 1.0;
        [self.barTintLayer addSublayer:layer];
        atIndex++;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if ([self presentedViewController] != nil && ![self presentedViewController].beingDismissed) {
        return [self presentedViewController];
    }
    return [self childViewControllers].lastObject;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if ([self presentedViewController] != nil && ![self presentedViewController].beingDismissed) {
        return [self presentedViewController];
    }
    return [self childViewControllers].lastObject;
}

- (BOOL)prefersStatusBarHidden {
    return [self childViewControllerForStatusBarHidden].prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self childViewControllerForStatusBarStyle].preferredStatusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self childViewControllerForStatusBarStyle].preferredStatusBarUpdateAnimation;
}

- (CALayer *)barTintLayer {
    if (_barTintLayer == nil) {
        _barTintLayer = [CALayer layer];
    }
    return _barTintLayer;
}

@end
