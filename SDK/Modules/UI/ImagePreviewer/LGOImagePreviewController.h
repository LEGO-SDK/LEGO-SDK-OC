//
//  LGOImagePreviewController.h
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOImagePreviewZoomingScrollView.h"

@interface LGOImagePreviewFrameController
    : UIPageViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

+ (UIWindow *)window;

- (instancetype)initWithURLs:(NSArray<NSURL *> *)URLs defaultURL:(NSURL *)defaultURL;

- (void)showInNavigationController:(UINavigationController *)navigationController;

- (void)showInViewController:(UIViewController *)viewController;

- (void)dismiss;

@end

@interface LGOImagePreviewImageViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) LGOImagePreviewZoomingScrollView *scrollView;

- (instancetype)init:(NSURL *)URL;

- (instancetype)init:(NSURL *)URL image:(UIImage *)image;

@end