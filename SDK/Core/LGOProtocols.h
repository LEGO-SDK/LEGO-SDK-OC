//
//  LGOProtocols.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LGORequestContext, LGORequest, LGOResponse, LGORequestable, LGOModule;

typedef void (^LGORequestableAsynchronizeBlock)(LGOResponse *_Nonnull response);

@interface LGORequestContext : NSObject

@property(nonatomic, weak) NSObject *_Nullable sender;
@property(nonatomic, strong) UIViewController *_Nullable viewController;

- (nullable UIViewController *)requestViewController;

- (nullable UIView *)requestWebView;  // may return UIWebView or WKWebView

@end

@interface LGORequest : NSObject

@property(nonatomic, strong) LGORequestContext *_Nullable context;

- (nonnull instancetype)initWithContext:(nullable LGORequestContext *)context;

@end

@interface LGOResponse : NSObject

@property (nonatomic, readonly) int status;
@property (nonatomic, copy) NSDictionary *_Nonnull metaData;

- (nonnull LGOResponse *)reject:(nonnull NSError *)error;
- (nonnull LGOResponse *)accept:(nullable NSDictionary *)metaData;
- (nonnull NSDictionary *)resData;

@end

@interface LGORequestable : NSObject

+ (nonnull LGORequestable *)rejectWithDomain:(nullable NSString *)domain
                                        code:(NSInteger)code
                                      reason:(nullable NSString *)reason;

- (void)requestAsynchronize:(nonnull LGORequestableAsynchronizeBlock)callbackBlock;

- (nonnull LGOResponse *)requestSynchronize;

@end

@interface LGOModule : NSObject

@property (nonatomic, assign) BOOL isSynchronize;

@property (nonatomic, assign) NSInteger ver;

- (nonnull LGORequestable *)buildWithRequest:(nonnull LGORequest *)request;

- (nonnull LGORequestable *)buildWithDictionary:(nonnull NSDictionary *)dictionary
                                        context:(nonnull LGORequestContext *)context;

- (nullable NSDictionary *)synchronizeResponse:(nullable UIView *)webView;

@end