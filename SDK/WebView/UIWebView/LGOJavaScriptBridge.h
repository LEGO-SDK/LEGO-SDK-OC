//
//  LGOJavaScriptBridge.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
@import JavaScriptCore;

@class LGORequestContext;

typedef void (^LGOJSMessageCallCompletionBlock)(NSDictionary<NSString *, id> *_Nonnull result);

@interface LGOJSMessage : NSObject

@property(nonatomic, copy) NSString *_Nonnull messageID;
@property(nonatomic, copy) NSString *_Nonnull moduleName;
@property(nonatomic, copy) NSDictionary<NSString *, id> *_Nonnull requestParams;
@property(nonatomic, strong) NSNumber *_Nonnull callbackID;

+ (nullable LGOJSMessage *)newMessageWithJSONString:(nonnull NSString *)JSONString;

- (void)callWithCompletionBlock:(nonnull LGOJSMessageCallCompletionBlock)completionBlock
                        context:(nullable LGORequestContext *)context;

@end

@protocol LGOJSBridgeExport<JSExport>

+ (nonnull NSString *)bridgeScript:(nonnull JSValue *)JSValue;

+ (void)exec:(nonnull JSValue *)JSONString;

+ (void)setTitle:(nonnull JSValue *)title;

@end

@interface LGOJSBridge : NSObject<LGOJSBridgeExport>

@end

@interface LGOJavaScriptBridge : NSObject

+ (void)configureWithJSContext:(nonnull JSContext *)context;

@end
