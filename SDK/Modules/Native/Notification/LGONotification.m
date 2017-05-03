//
//  LGONotification.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGONotification.h"

static NSMutableArray *observers;
static NSNumber *observersGCLock;

@interface LGONotification ()

+ (void)runGC;

@end

@interface LGONotificationObserver : NSObject

@property(nonatomic, assign) BOOL deleted;
@property(nonatomic) __weak NSObject *webView;
@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) id observer;

@end

@implementation LGONotificationObserver

@end

@interface LGONotificationRequest : LGORequest

@property(nonatomic, strong) NSString *opt;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) id _Nullable aPostObject;
@property(nonatomic, strong) NSDictionary<NSString *, id> *aPostUserInfo;

@end

@implementation LGONotificationRequest

@end

@interface LGONotificationResponse : LGOResponse

@property(nonatomic, strong) id _Nullable object;
@property(nonatomic, strong) NSDictionary *_Nullable userInfo;

@end

@implementation LGONotificationResponse

- (NSDictionary *)resData {
    id objectValue = @"";
    NSDictionary *userInfoValue = @{};
    if (self.object && ([self.object isKindOfClass:[NSString class]] || [self.object isKindOfClass:[NSNumber class]])) {
        objectValue = self.object;
    }
    if (self.userInfo != nil) {
        if ([NSJSONSerialization isValidJSONObject:self.userInfo]) {
            userInfoValue = self.userInfo;
        } else {
            NSMutableDictionary *outputInfo = [NSMutableDictionary new];
            for (NSString *key in self.userInfo) {
                id value = [self.userInfo objectForKey:key];
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    [outputInfo setObject:value forKey:key];
                }
            }
            userInfoValue = [outputInfo copy];
        }
    }
    return @{ @"object" : objectValue, @"userInfo" : userInfoValue };
}

@end

@interface LGONotificationOperation : LGORequestable

@property(nonatomic, strong) LGONotificationRequest *request;

@end

@implementation LGONotificationOperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    [LGONotification runGC];
    if ([self.request.opt isEqualToString:@"create"]) {
        id observer = [[NSNotificationCenter defaultCenter]
            addObserverForName:self.request.name
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *_Nonnull note) {
                      NSDictionary *userInfo = @{};
                      if ([note isKindOfClass:[NSDictionary class]]) {
                          userInfo = (NSDictionary *)note;
                      }
                      NSString *object = note.object ? note.object : @"";

                      LGONotificationResponse *response = [LGONotificationResponse new];
                      response.object = object;
                      response.userInfo = userInfo;
                      callbackBlock([response accept:nil]);
                    }];
        if (self.request.context.sender != nil) {
            LGONotificationObserver *item = [LGONotificationObserver new];
            item.webView = self.request.context.sender;
            item.name = self.request.name;
            item.observer = observer;
            [observers addObject:item];
        }
    } else if ([self.request.opt isEqualToString:@"delete"]) {
        for (LGONotificationObserver *item in observers) {
            if (!item.deleted && [item.webView isEqual:self.request.context.sender]) {
                if (self.request.name.length > 0 && [self.request.name isEqualToString:item.name]) {
                    item.deleted = YES;
                    [[NSNotificationCenter defaultCenter] removeObserver:item.observer];
                }
            }
        }
        callbackBlock([[LGOResponse new] accept:nil]);
    } else if ([self.request.opt isEqualToString:@"post"]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
          [[NSNotificationCenter defaultCenter] postNotificationName:self.request.name
                                                              object:self.request.aPostObject
                                                            userInfo:self.request.aPostUserInfo];
        }];
    } else {
        callbackBlock([[LGOResponse new] reject:[NSError errorWithDomain:@"Native.Notification"
                                                                    code:-3
                                                                userInfo:@{
                                                                    NSLocalizedDescriptionKey : @"Invalid opt value."
                                                                }]]);
    }
}

@end

@implementation LGONotification

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.Notification" instance:[self new]];
}

+ (NSArray *)observers {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      observers = [NSMutableArray new];
    });
    return observers;
}

+ (NSNumber *)observersGCLock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      observersGCLock = [NSNumber numberWithInteger:0];
    });
    return observersGCLock;
}

+ (void)runGC {
    @synchronized([self observersGCLock]) {
        NSMutableArray<LGONotificationObserver *> *weakObservers = [NSMutableArray new];
        NSMutableArray<LGONotificationObserver *> *nonweakObservers = [NSMutableArray new];
        for (LGONotificationObserver *item in [self observers]) {
            if (item.deleted) {
                [weakObservers addObject:item];
            }
            else if (item.webView != nil) {
                [nonweakObservers addObject:item];
            }
            else {
                [weakObservers addObject:item];
            }
        }
        observers = nonweakObservers;
        for (LGONotificationObserver *item in weakObservers) {
            if (!item.deleted && item.observer != nil) {
                [[NSNotificationCenter defaultCenter] removeObserver:item.observer];
            }
        }
    }
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGONotificationRequest class]]) {
        LGONotificationOperation *operation = [LGONotificationOperation new];
        operation.request = (LGONotificationRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.Notification" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    NSString *name = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : nil;
    if (name != nil) {
        NSString *opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"add";
        LGONotificationRequest *request = [LGONotificationRequest new];
        request.name = name;
        request.opt = opt;
        request.context = context;
        NSString *aPostObject =
            [dictionary[@"aPostObject"] isKindOfClass:[NSString class]] ? dictionary[@"aPostObject"] : nil;
        if (aPostObject != nil) {
            request.aPostObject = aPostObject;
        }
        NSDictionary *aPostUserInfo =
            [dictionary[@"aPostUserInfo"] isKindOfClass:[NSDictionary class]] ? dictionary[@"aPostUserInfo"] : nil;
        if (aPostUserInfo != nil) {
            request.aPostUserInfo = aPostUserInfo;
        }
        return [self buildWithRequest:request];
    }
    return [LGORequestable rejectWithDomain:@"Native.Notification" code:-2 reason:@"Name require."];
}

@end
