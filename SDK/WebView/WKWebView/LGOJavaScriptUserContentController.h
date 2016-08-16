//
//  LGOJavaScriptUserContentController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>

@class LGORequestContext;

typedef void (^LGOWKMessageCallCompletionBlock)(NSDictionary<NSString *, id> *_Nonnull result);

@interface LGOWKMessage : NSObject

@property(nonatomic, copy) NSString *_Nonnull messageID;
@property(nonatomic, copy) NSString *_Nonnull moduleName;
@property(nonatomic, copy) NSDictionary<NSString *, id> *_Nonnull requestParams;
@property(nonatomic, strong) NSNumber *_Nonnull callbackID;

+ (nullable LGOWKMessage *)newMessageWithJSONString:(nonnull NSString *)JSONString;

- (void)callWithCompletionBlock:(nonnull LGOWKMessageCallCompletionBlock)completionBlock
                        context:(nullable LGORequestContext *)context;

@end

@interface LGOJavaScriptUserContentController : WKUserContentController<WKScriptMessageHandler>

@property(nonatomic, weak) WKWebView *_Nullable webView;

- (void)addPrescripts;

@end
