//
//  LGOAlertView.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOAlertView.h"
#import "LGOBuildFailed.h"
#import "LGOCore.h"

@interface LGOAlertViewRequest : LGORequest

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) NSArray<NSString *> *buttonTitles;

@end

@implementation LGOAlertViewRequest

@end

@interface LGOAlertViewResponse : LGOResponse

@property(nonatomic, assign) NSInteger buttonIndex;

@end

@implementation LGOAlertViewResponse

- (NSDictionary *)resData {
    return @{ @"buttonIndex" : [NSNumber numberWithInteger:self.buttonIndex] };
}

@end

@class LGOAlertViewOperation;

static LGOAlertViewOperation *currentOperation;

@interface LGOAlertViewOperation : LGORequestable<UIAlertViewDelegate>

@property(nonatomic, strong) LGOAlertViewRequest *request;
@property(nonatomic, strong) UIAlertView *alertView;
@property(nonatomic, copy) LGORequestableAsynchronizeBlock responseBlock;

@end

@implementation LGOAlertViewOperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    currentOperation = self;
    self.responseBlock = callbackBlock;
    self.alertView = [[UIAlertView alloc] initWithTitle:self.request.title
                                                message:self.request.message
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil, nil];
    if (self.request.buttonTitles && self.request.buttonTitles.count > 0) {
        for (NSString *item in self.request.buttonTitles) {
            [self.alertView addButtonWithTitle:item];
        }
    } else {
        [self.alertView addButtonWithTitle:@"OK"];
    }
    [self.alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.responseBlock) {
        LGOAlertViewResponse *response = [LGOAlertViewResponse new];
        response.buttonIndex = buttonIndex;
        self.responseBlock(response);
    }
}

@end

@implementation LGOAlertView

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOAlertViewRequest class]]) {
        LGOAlertViewOperation *operation = [LGOAlertViewOperation new];
        operation.request = (LGOAlertViewRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOAlertViewRequest *request = [LGOAlertViewRequest new];
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : nil;
    request.message = [dictionary[@"message"] isKindOfClass:[NSString class]] ? dictionary[@"message"] : nil;
    request.buttonTitles =
        [dictionary[@"buttonTitles"] isKindOfClass:[NSArray class]] ? dictionary[@"buttonTitles"] : nil;
    return [self buildWithRequest:request];
}

@end
