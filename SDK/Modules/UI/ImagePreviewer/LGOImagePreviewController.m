//
//  LGOImagePreviewController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOImagePreviewController.h"
#import "LGOImagePreviewZoomingScrollView.h"

@interface LGOImagePreviewFrameController ()

@property (nonatomic, strong) NSArray<NSURL*> *URLs;
@property (nonatomic, strong) NSURL *defaultURL;
@property (nonatomic, strong) NSMutableDictionary<NSString*, UIImage*> *imageCaches;

@end

@implementation LGOImagePreviewFrameController

static UIWindow *window;

- (instancetype)initWithURLs:(NSArray<NSURL*>*)theURLs defaultURL:(NSURL*)defaultURL{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self) {
        _URLs = theURLs;
        _defaultURL = defaultURL;
        _imageCaches = [[NSMutableDictionary alloc] init];
        if ([self respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")]) {
            [self setValue:@(YES) forKey:@"lgo_navigationBarHidden"];
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.defaultURL != nil){
        LGOImagePreviewImageViewController *vc = [[LGOImagePreviewImageViewController alloc] init:self.defaultURL];
        NSMutableArray<LGOImagePreviewImageViewController*> *vcs = [NSMutableArray new];
        [vcs addObject:vc];
        [self setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    else {
        NSURL *firstURL = self.URLs.firstObject;
        if (firstURL != nil){
            [self setViewControllers:@[[[LGOImagePreviewImageViewController alloc] init:firstURL]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
    }
    self.delegate = self;
    self.dataSource = self;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")]) {}
    else {
        if (self.navigationController != nil){
            self.navigationController.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self respondsToSelector:NSSelectorFromString(@"lgo_navigationBarHidden")]) {}
    else {
        if (self.navigationController != nil){
            [self.navigationController setNavigationBarHidden:NO animated:animated];
        }
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    UIViewController *firtVC = self.viewControllers ? self.viewControllers.firstObject : nil;
    LGOImagePreviewImageViewController *pageVC = [firtVC isKindOfClass:[LGOImagePreviewImageViewController class]] ? (LGOImagePreviewImageViewController*)firtVC : nil;
    if (pageVC != nil){
        NSInteger indexAtPage = [self.URLs indexOfObjectPassingTest:^BOOL(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.absoluteString isEqualToString:[pageVC.URL absoluteString] ]){
                return YES;
            }
            return NO;
        }];
        if (indexAtPage != NSNotFound) {
            if (indexAtPage + 1 < self.URLs.count ){
                NSURL *keyURL = self.URLs[indexAtPage+1];
                if (keyURL != nil){
                    return [[LGOImagePreviewImageViewController alloc] init:keyURL image:[self.imageCaches valueForKey:[keyURL absoluteString]]];
                }
            }
        }
        
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    UIViewController *firtVC = self.viewControllers ? self.viewControllers.firstObject : nil;
    LGOImagePreviewImageViewController *pageVC = [firtVC isKindOfClass:[LGOImagePreviewImageViewController class]] ? (LGOImagePreviewImageViewController*)firtVC : nil;
    if (pageVC != nil){
        NSInteger indexAtPage = [self.URLs indexOfObjectPassingTest:^BOOL(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.absoluteString isEqualToString:[pageVC.URL absoluteString] ]){
                return YES;
            }
            return NO;
        }];
        if (indexAtPage != NSNotFound) {
            if (indexAtPage - 1 >= 0){
                NSURL *keyURL = self.URLs[indexAtPage-1];
                if (keyURL != nil){
                    return [[LGOImagePreviewImageViewController alloc] init:keyURL image:[self.imageCaches valueForKey:[keyURL absoluteString]]];
                }
            }
        }

    }
    return nil;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)showInNavigationController:(UINavigationController*)navigationController{
    [navigationController pushViewController:self animated:YES];
}

- (void)showInViewController:(UIViewController*)viewController{
    [viewController presentViewController:self animated:YES completion:nil];
}

- (void)dismiss{
    if (self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (UIWindow *)window{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return window;
}

@end


@implementation LGOImagePreviewImageViewController

- (instancetype)init:(NSURL*)URL
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _URL = URL;
        _scrollView = [LGOImagePreviewZoomingScrollView new];
    }
    return self;
}

- (instancetype)init:(NSURL*)URL image:(UIImage*)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _URL = URL;
        _image = image;
        _scrollView = [LGOImagePreviewZoomingScrollView new];
    }
    return self;
}

- (void)viewDidLoad{
    [self.view addSubview:self.scrollView];
    [self loadImage];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self configureZoom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self navigationController] != nil) {
        [[self navigationController]setNavigationBarHidden:YES animated:NO];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.scrollView.frame = [UIScreen mainScreen].bounds;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateWithDuration:duration animations:^{
        [self configureZoomToOrientation:toInterfaceOrientation];
    }];
}

- (void)loadImage{
    if (self.image != nil){
        self.scrollView.imageView.image = self.image;
        self.scrollView.imageView.frame = CGRectMake(0.0, 0.0, self.image.size.width, self.image.size.height);
        [self configureZoom];
        return ;
    }
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:15.0];
    [self.scrollView.activityIndicator startAnimating];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        [self.scrollView.activityIndicator stopAnimating];
        if (data != nil && !connectionError){
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image != nil){
                self.scrollView.imageView.image = image;
                self.scrollView.imageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
                [self configureZoom];
                if ([self.parentViewController isKindOfClass:[LGOImagePreviewFrameController class]]){
                    [((LGOImagePreviewFrameController*)self.parentViewController).imageCaches setObject:image forKey:[self.URL absoluteString]];
                }
            }
        }
        else {
            [self.scrollView showErrorView];
        }
    }];
}

- (void)configureZoom{
    {
        CGFloat minScale = 1.0;
        UIImage *image = self.scrollView.imageView.image;
        if (image != nil){
            minScale = [UIScreen mainScreen].bounds.size.width / image.size.width;
        }
        self.scrollView.minimumZoomScale = minScale;
    }
    self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale * 3.0;
    self.scrollView.delegate = self;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (void)configureZoomToOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ){
        {
            CGFloat minScale = 1.0;
            UIImage *image = self.scrollView.imageView.image;
            if (image != nil){
                minScale = [UIScreen mainScreen].bounds.size.width / image.size.width;
            }
            self.scrollView.minimumZoomScale = minScale;
        }
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale * 3.0;
        self.scrollView.delegate = self;
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
    else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)){
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.scrollView.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
}

@end
