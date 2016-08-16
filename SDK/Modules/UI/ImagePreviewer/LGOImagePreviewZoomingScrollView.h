//
//  LGOImagePreviewZoomingScrollView.h
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGOImagePreviewZoomingScrollView : UIScrollView<UIActionSheetDelegate>
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (void)showErrorView;

@end
