//
//  LGONavigationBar.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGONavigationBar.h"
#import "UIViewController+LGONavigationBar.h"

@interface LGONavigationBarRequest : LGORequest

@property(nonatomic, strong) NSNumber *hidden;  // boolean
@property(nonatomic, assign) BOOL animated;     // boolean

@end

@implementation LGONavigationBarRequest

@end

@interface LGONavigationBarOperation : LGORequestable

@property(nonatomic, strong) LGONavigationBarRequest *request;

@end

@implementation LGONavigationBarOperation

- (LGOResponse *)requestSynchronize {
    UIViewController *viewController = [self.request.context requestViewController];
    if (viewController != nil) {
        if ([self.request.hidden isEqualToNumber:@(YES)]) {
            viewController.lgo_navigationBarHidden = YES;
        } else if (self.request.hidden != nil) {
            viewController.lgo_navigationBarHidden = NO;
        }
    }
    [viewController lgo_setNeedsNavigationBarAppearanceUpdate:self.request.animated];
    return [LGOResponse new];
}

@end

@implementation LGONavigationBar

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGONavigationBarRequest class]]) {
        LGONavigationBarOperation *operation = [LGONavigationBarOperation new];
        operation.request = (LGONavigationBarRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGONavigationBarRequest *request = [LGONavigationBarRequest new];
    request.context = context;
    request.hidden = [dictionary[@"hidden"] isKindOfClass:[NSNumber class]] ? dictionary[@"hidden"] : nil;
    request.animated =
        [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? [dictionary[@"animated"] boolValue] : YES;
    return [self buildWithRequest:request];
}

@end
