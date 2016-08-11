//
//  LGOActionSheet.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOActionSheet.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"

@interface LGOActionSheetRequest: LGORequest

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSArray<NSString *>  *buttonTitles;
@property (nonatomic, assign) int dangerButton;
@property (nonatomic, strong) NSString  *cancelButton;

@end

@implementation LGOActionSheetRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dangerButton = -1;
    }
    return self;
}

@end

@interface LGOActionSheetResponse: LGOResponse

@property (nonatomic, assign) NSInteger buttonIndex;

@end

@implementation LGOActionSheetResponse

- (NSDictionary *)toDictionary {
    return @{
             @"buttonIndex": [NSNumber numberWithInteger:self.buttonIndex]
             };
}

@end

@class LGOActionSheetOperation;

static LGOActionSheetOperation *currentOperation;

@interface LGOActionSheetOperation: LGORequestable<UIActionSheetDelegate>

@property (nonatomic, strong) LGOActionSheetRequest *request;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, copy) LGORequestableAsynchronizeBlock responseBlock;

@end

@implementation LGOActionSheetOperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    currentOperation = self;
    self.responseBlock = callbackBlock;
    self.actionSheet = [UIActionSheet new];
    self.actionSheet.delegate = self;
    if (self.request.title.length > 0) {
        self.actionSheet.title = self.request.title;
    }
    if (self.request.buttonTitles != nil && self.request.buttonTitles.count > 0){
        for (NSString *item in self.request.buttonTitles) {
            [self.actionSheet addButtonWithTitle:item];
        }
    }
    if (self.request.cancelButton.length > 0){
        [self.actionSheet addButtonWithTitle:self.request.cancelButton];
        self.actionSheet.cancelButtonIndex = self.actionSheet.numberOfButtons - 1;
    }
    self.actionSheet.destructiveButtonIndex = self.request.dangerButton;
    
    if ([UIApplication sharedApplication].keyWindow != nil){
        [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.responseBlock){
        LGOActionSheetResponse *response = [LGOActionSheetResponse new];
        response.buttonIndex = buttonIndex;
        self.responseBlock(response);
    }
}

@end

@implementation LGOActionSheet

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOActionSheetRequest class]]){
        LGOActionSheetOperation *operation = [LGOActionSheetOperation new];
        operation.request = (LGOActionSheetRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    
    LGOActionSheetRequest *request = [LGOActionSheetRequest new];
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : nil;;
    request.buttonTitles = [dictionary[@"buttonTitles"] isKindOfClass:[NSArray class]] ? dictionary[@"buttonTitles"] : nil;
    request.cancelButton = [dictionary[@"cancelButton"] isKindOfClass:[NSString class]] ? dictionary[@"cancelButton"] : @"取消";
    NSNumber *dangerButton = [dictionary[@"dangerButton"] isKindOfClass:[NSNumber class]] ? dictionary[@"dangerButton"] : nil;
    if (dangerButton != nil) {
        request.dangerButton = dangerButton.intValue;
    }
    return [self buildWithRequest:request];
}

@end
