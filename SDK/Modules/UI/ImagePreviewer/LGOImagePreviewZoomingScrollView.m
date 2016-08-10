//
//  LGOImagePreviewZoomingScrollView.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOImagePreviewZoomingScrollView.h"
#import "LGOImagePreviewController.h"

@interface LGOImagePreviewZoomingScrollView ()

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIActionSheet *longPressActionSheet;
@property (nonatomic, strong) UILabel *errorView;

@end

@implementation LGOImagePreviewZoomingScrollView

- (void)dealloc{
    self.longPressActionSheet.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProps];
        [self addSubview:self.imageView];
        [self addSubview:self.activityIndicator];
        [self.doubleTapGesture addTarget:self action:@selector(handleDoubleTapped:)];
        [self.imageView addGestureRecognizer:self.doubleTapGesture];
        [self.singleTapGesture addTarget:self action:@selector(handleSingleTapped:)];
        [self.longPressGesture addTarget:self action:@selector(handleLongPressed:)];
        [self.imageView addGestureRecognizer:self.longPressGesture];
        [self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
        [self.imageView addGestureRecognizer:self.singleTapGesture];
        self.activityIndicator.hidesWhenStopped = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapped:)]];
    }
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    if (self.imageView.image != nil){
        self.imageView.frame = self.bounds;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    if (frameToCenter.size.width < boundsSize.width){
        frameToCenter.origin.x = ( boundsSize.width - frameToCenter.size.width ) / 2.0;
    }
    else {
        frameToCenter.origin.x = 0.0;
    }
    if (frameToCenter.size.height < boundsSize.height){
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0;
    }
    else{
        frameToCenter.origin.y = 0.0;
    }
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
    }
    self.activityIndicator.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    self.errorView.frame = self.bounds;
}

- (void)showErrorView{
    [self addSubview:self.errorView];
    self.errorView.frame = self.bounds;
    [self.errorView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapped:)]];
}

- (void)handleSingleTapped:(UITapGestureRecognizer*)sender{
    LGOImagePreviewFrameController *viewController = [self requestViewController];
    if (viewController != nil){
        [viewController dismiss];
    }
}

- (void)handleDoubleTapped:(UITapGestureRecognizer*)sender{
    if (self.zoomScale == self.maximumZoomScale){
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        CGPoint touchPoint = [sender locationOfTouch:0 inView:self.imageView];
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

- (void)handleLongPressed:(UILongPressGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan){
        [self.longPressActionSheet showInView:[LGOImagePreviewFrameController window]];
        self.longPressActionSheet.delegate = self;
    }
}

- (LGOImagePreviewFrameController*) requestViewController {
    UIResponder *next = [self nextResponder];
    for (int i = 0; i< 100; i++) {
        if ([next isKindOfClass:[LGOImagePreviewFrameController class]]){
            return (LGOImagePreviewFrameController*)next;
        }
        else if (next != nil) {
            next = [next nextResponder];
        }
    }
    return nil;
}

- (void)setupProps{
    _singleTapGesture = [UITapGestureRecognizer new];
    _singleTapGesture.numberOfTapsRequired = 1;
    _doubleTapGesture = [UITapGestureRecognizer new];
    _doubleTapGesture.numberOfTapsRequired = 2;
    _longPressGesture = [UILongPressGestureRecognizer new];
    _longPressActionSheet = [UIActionSheet new];
    [_longPressActionSheet addButtonWithTitle:@"保存图片"];
    [_longPressActionSheet addButtonWithTitle:@"复制图片"];
    [_longPressActionSheet addButtonWithTitle:@"取消"];
    _longPressActionSheet.cancelButtonIndex = 2;
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _errorView = [UILabel new];
    _errorView.font = [UIFont systemFontOfSize:16.0];
    _errorView.textColor = [UIColor whiteColor];
    _errorView.textAlignment = NSTextAlignmentCenter;
    _errorView.text = @"无法加载图片";
    _errorView.userInteractionEnabled = YES;
}

@end




@interface LGOImagePreviewZoomingScrollView (Delegator)
    
@end

@implementation LGOImagePreviewZoomingScrollView (Delegator)

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet == self.longPressActionSheet){
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"保存图片"]){
            UIImage *image = self.imageView.image;
            if (image != nil){
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
        }
        else if ([title isEqualToString:@"复制图片"]){
            UIImage *image = self.imageView.image;
            NSData *data = UIImagePNGRepresentation(image);
            if (image != nil && data != nil){
                [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"public.png"];
            }
        }
    }
}

@end



