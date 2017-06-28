//
//  LGONavigationItem.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "LGOCore.h"
#import "LGONavigationItem.h"

@interface LGONavigationItemRequest : LGORequest

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *leftItem;
@property(nonatomic, strong) NSString *rightItem;
@property(nonatomic, strong) NSString *backItem;

@end

@implementation LGONavigationItemRequest

@end

@interface LGONavigationItemResponse : LGOResponse

@property(nonatomic, assign) BOOL leftTapped;
@property(nonatomic, assign) BOOL rightTapped;

@end

@implementation LGONavigationItemResponse

- (NSDictionary *)resData {
    return @{
        @"leftTapped" : [NSNumber numberWithBool:self.leftTapped],
        @"rightTapped" : [NSNumber numberWithBool:self.rightTapped]
    };
}

@end

@interface LGONavigationItemOperation : LGORequestable

@property (nonatomic, copy) LGORequestableAsynchronizeBlock responseBlock;
@property (nonatomic, retain) LGONavigationItemRequest *request;

@end

@implementation LGONavigationItemOperation

UInt16 LGONavigationItemOperationPinKey;

- (LGOResponse *)requestSynchronize {
    UIViewController *viewController = [self requestViewController];
    if (viewController == nil) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.NavigationItem"
                                                             code:-2
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"ViewController not found."
                                                         }]];
    }
    if (self.request.title != nil) {
        viewController.title = self.request.title;
    }
    if (self.request.leftItem != nil) {
        if ([self.request.leftItem rangeOfString:@".png"].location != NSNotFound) {
            NSURL *relativeURL = nil;
            UIView *webView = self.request.context.requestWebView;
            if (webView != nil && [webView isKindOfClass:[UIWebView class]]) {
                relativeURL = ((UIWebView *)webView).request.URL;
            }
            if (webView != nil && [webView isKindOfClass:[WKWebView class]]) {
                relativeURL = ((WKWebView *)webView).URL;
            }
            NSURL *URL = [NSURL URLWithString:self.request.leftItem relativeToURL:relativeURL];
            if (URL != nil) {
                [self imageBarButtonItem:URL
                         completionBlock:^(UIBarButtonItem *item) {
                             item.tag = 100;
                             viewController.navigationItem.leftBarButtonItem = item;
                         }];
            }
        }
        else {
            UIBarButtonItem *leftItem = [self textBarButtonItem:self.request.leftItem];
            if (leftItem != nil) {
                leftItem.tag = 100;
                viewController.navigationItem.leftBarButtonItem = leftItem;
            }
        }
        [self pinToViewController:viewController];
    }
    if (self.request.rightItem != nil) {
        if ([self.request.rightItem rangeOfString:@".png"].location != NSNotFound) {
            NSURL *relativeURL = nil;
            UIView *webView = self.request.context.requestWebView;
            if (webView != nil && [webView isKindOfClass:[UIWebView class]]) {
                relativeURL = ((UIWebView *)webView).request.URL;
            }
            if (webView != nil && [webView isKindOfClass:[WKWebView class]]) {
                relativeURL = ((WKWebView *)webView).URL;
            }
            NSURL *URL = [NSURL URLWithString:self.request.rightItem relativeToURL:relativeURL];
            if (URL != nil) {
                [self imageBarButtonItem:URL
                         completionBlock:^(UIBarButtonItem *item) {
                             item.tag = 101;
                             viewController.navigationItem.rightBarButtonItem = item;
                         }];
            }
        }
        else {
            UIBarButtonItem *rightItem = [self textBarButtonItem:self.request.rightItem];
            if (rightItem != nil) {
                rightItem.tag = 101;
                viewController.navigationItem.rightBarButtonItem = rightItem;
            }
        }
        [self pinToViewController:viewController];
    }
    LGONavigationItemResponse *response = [LGONavigationItemResponse new];
    response.leftTapped = NO;
    response.rightTapped = NO;
    return [response accept:nil];
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    self.responseBlock = callbackBlock;
    callbackBlock([self requestSynchronize]);
}

- (UIViewController *)requestViewController {
    UIView *view =
        [self.request.context.sender isKindOfClass:[UIView class]] ? (UIView *)self.request.context.sender : nil;
    if (view != nil) {
        UIResponder *next = [view nextResponder];
        for (int count = 0; count < 100; count++) {
            if ([next isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)next;
            } else {
                if (next != nil) {
                    next = [next nextResponder];
                }
            }
        }
    }
    return nil;
}

- (void)imageBarButtonItem:(NSURL *)URL completionBlock:(void (^)(UIBarButtonItem *item))completionBlock {
    NSURLRequest *request =
        [[NSURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:15.0];
    CGFloat scale = 2.0;
    if ([URL.absoluteString rangeOfString:@"@3x.png"].location != NSNotFound ||
        [URL.absoluteString rangeOfString:@"%403x"].location != NSNotFound) {
        scale = 3.0;
    }
    if ([URL.scheme isEqualToString:@"file"]) {
        NSData *data = [NSData dataWithContentsOfURL:URL];
        if (data == nil) {
            return;
        }
        UIImage *image = [[UIImage alloc] initWithData:data scale:scale];
        if (image == nil) {
            return;
        }
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(handleBarButtonItemTapped:)];
        completionBlock(item);
    }
    else {
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *_Nullable response, NSData *_Nullable data,
                                                   NSError *_Nullable connectionError) {
                                   if (data == nil) {
                                       return;
                                   }
                                   UIImage *image = [[UIImage alloc] initWithData:data scale:scale];
                                   if (image == nil) {
                                       return;
                                   }
                                   UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                                            initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                            style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(handleBarButtonItemTapped:)];
                                   completionBlock(item);
                               }];
    }   
}

- (UIBarButtonItem *)textBarButtonItem:(NSString *)text {
    return [[UIBarButtonItem alloc] initWithTitle:text
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(handleBarButtonItemTapped:)];
}

- (void)pinToViewController:(UIViewController *)viewController {
    objc_setAssociatedObject(viewController, &LGONavigationItemOperationPinKey, self,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)handleBarButtonItemTapped:(UIBarButtonItem *)sender {
    if (self.responseBlock) {
        LGONavigationItemResponse *response = [LGONavigationItemResponse new];
        response.leftTapped = sender.tag == 100;
        response.rightTapped = sender.tag == 101;
        self.responseBlock([response accept:nil]);
    }
}

@end

@implementation LGONavigationItem

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.NavigationItem" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGONavigationItemRequest class]]) {
        LGONavigationItemOperation *operation = [LGONavigationItemOperation new];
        operation.request = (LGONavigationItemRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.NavigationItem" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGONavigationItemRequest *request = [LGONavigationItemRequest new];
    request.context = context;
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : nil;
    request.leftItem = [dictionary[@"leftItem"] isKindOfClass:[NSString class]] ? dictionary[@"leftItem"] : nil;
    request.rightItem = [dictionary[@"rightItem"] isKindOfClass:[NSString class]] ? dictionary[@"rightItem"] : nil;
    request.backItem = [dictionary[@"backItem"] isKindOfClass:[NSString class]] ? dictionary[@"backItem"] : nil;
    return [self buildWithRequest:request];
}

@end
