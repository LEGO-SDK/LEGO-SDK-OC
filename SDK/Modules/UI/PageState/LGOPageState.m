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


@interface LGOPageState()

@property (nonatomic, weak) id<LGOPageStateProtocol> pageStateObserver;

@end

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
    
//    - (void)pageDidLoad;
//
//    - (void)pageWillAppear;
//    - (void)pageDidAppear;
//
//    - (void)pageWillDisappear;
//    - (void)pageDidDisappear;
//
//    - (void)pageDealloc;

    [targetViewController addHook:^{
        [[LGOPageState sharedInstance].pageStateObserver pageDidLoad];
        callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateDisappear] accept:nil]);
    } forMethod:@"viewDidLoad"];
    
    [targetViewController addHook:^{
        [[LGOPageState sharedInstance].pageStateObserver pageDidAppear];
        callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateAppear] accept:nil]);
    } forMethod:@"viewDidAppear"];
    [targetViewController addHook:^{
        [[LGOPageState sharedInstance].pageStateObserver pageDidDisappear];
        callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateDisappear] accept:nil]);
    } forMethod:@"viewDidDisappear"];
    
    [targetViewController addHook:^{
        [[LGOPageState sharedInstance].pageStateObserver pageDealloc];
        callbackBlock([[[LGOPageStateResponse alloc] initWithCurrentState:kStateDisappear] accept:nil]);
    } forMethod:@"dealloc"];
}

@end

@implementation LGOPageState

+ (LGOPageState *)sharedInstance {
    static LGOPageState *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.PageState" instance:[self new]];
}

- (void)registerPageStateObserver:(id<LGOPageStateProtocol>)pageStateObserver {
    _pageStateObserver = pageStateObserver;
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOPageStateOperation *operation = [LGOPageStateOperation new];
    operation.context = context;
    return operation;
}

@end
