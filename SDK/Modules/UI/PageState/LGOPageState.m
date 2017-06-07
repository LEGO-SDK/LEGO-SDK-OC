//
//  LGOPageState.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/6/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOPageState.h"
#import "LGOCore.h"
#import "LGOBaseViewController.h"
#import <objc/runtime.h>

static NSString *kStateInactive = @"inactive";
static NSString *kStateActive = @"active";
static NSString *kStateAppear = @"appear";
static NSString *kStateDisappear = @"disappear";

@interface LGOPageStateResponse : LGOResponse

@property (nonatomic, copy) NSString *currentState;

@end

@implementation LGOPageStateResponse

- (instancetype)initWithCurrentState:(NSString *)currentState
{
    self = [super init];
    if (self) {
        _currentState = currentState;
    }
    return self;
}

- (NSDictionary *)resData {
    return @{
             @"currentState": self.currentState ?: @"",
             };
}

@end

@interface LGOPageStateOperation : LGORequestable

@property (nonatomic, strong) LGORequestContext *context;
@property (nonatomic, copy) NSArray *observers;

@end

@implementation LGOPageStateOperation

static int kLGOPageStateOperationIdentifier;

- (void)dealloc {
    for (id observer in self.observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    if (![[self.context requestViewController] isKindOfClass:[LGOBaseViewController class]]) {
        return;
    }
    LGOBaseViewController *targetViewController = (id)[self.context requestViewController];
    objc_setAssociatedObject(targetViewController,
                             &kLGOPageStateOperationIdentifier,
                             self,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.observers = @[
                       [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                           callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateInactive] accept:nil]);
                       }],
                       [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                           callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateActive] accept:nil]);
                       }],
                       ];
    [targetViewController addHook:^{
        callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateAppear] accept:nil]);
    } forMethod:@"viewDidAppear"];
    [targetViewController addHook:^{
        callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateDisappear] accept:nil]);
    } forMethod:@"viewDidDisappear"];
}

@end

@implementation LGOPageState

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.PageState" instance:[self new]];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOPageStateOperation *operation = [LGOPageStateOperation new];
    operation.context = context;
    return operation;
}

@end
