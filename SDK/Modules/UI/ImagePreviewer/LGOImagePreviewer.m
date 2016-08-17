//
//  LGOImagePreviewer.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOImagePreviewController.h"
#import "LGOImagePreviewer.h"

@interface LGOImagePreviewerRequest : LGORequest

@property(nonatomic, strong) NSArray<NSString *> *URLs;
@property(nonatomic, strong) NSString *currentURL;

@end

@implementation LGOImagePreviewerRequest

@end

@interface LGOImagePreviewerOperation : LGORequestable

@property(nonatomic, strong) LGOImagePreviewerRequest *request;

@end

@implementation LGOImagePreviewerOperation

- (LGOResponse *)requestSynchronize {
    NSMutableArray<NSURL *> *URLs = [NSMutableArray new];
    for (NSString *URLString in self.request.URLs) {
        [URLs addObject:[NSURL URLWithString:URLString]];
    }
    NSURL *defaultURL = self.request.currentURL ? [NSURL URLWithString:self.request.currentURL] : nil;
    LGOImagePreviewFrameController *viewController =
        [[LGOImagePreviewFrameController alloc] initWithURLs:URLs defaultURL:defaultURL];

    UIViewController *targetViewController = [self requestViewController];
    if (targetViewController != nil) {
        if (targetViewController.navigationController) {
            [viewController showInNavigationController:targetViewController.navigationController];
            return [[LGOResponse new] accept:nil];
        } else {
            [viewController showInViewController:targetViewController];
            return [[LGOResponse new] accept:nil];
        }
    } else {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"UI.ImagePreviewer"
                                                             code:-2
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"ViewController not found."
                                                         }]];
    }
}

- (UIViewController *)requestViewController {
    UIView *view =
        [self.request.context.sender isKindOfClass:[UIView class]] ? (UIView *)self.request.context.sender : nil;
    if (view != nil) {
        UIResponder *next = view.nextResponder;
        for (int i = 0; i < 100; i++) {
            if ([next isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)next;
            } else if (next != nil) {
                next = [next nextResponder];
            }
        }
    }
    return nil;
}

@end

@implementation LGOImagePreviewer

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.ImagePreviewer" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOImagePreviewerRequest class]]) {
        LGOImagePreviewerOperation *operation = [LGOImagePreviewerOperation new];
        operation.request = (LGOImagePreviewerRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.ImagePreviewer" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOImagePreviewerRequest *request = [LGOImagePreviewerRequest new];
    request.context = context;
    request.URLs = [dictionary[@"URLs"] isKindOfClass:[NSArray class]] ? dictionary[@"URLs"] : @[];
    request.currentURL = [dictionary[@"currentURL"] isKindOfClass:[NSString class]] ? dictionary[@"currentURL"] : nil;
    return [self buildWithRequest:request];
}

@end
