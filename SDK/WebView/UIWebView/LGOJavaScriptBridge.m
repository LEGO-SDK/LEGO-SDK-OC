//
//  LGOJavaScriptBridge.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOJavaScriptBridge.h"
#import "LGOProtocols.h"
#import "LGOCore.h"
#import "LGOWebView.h"
#import "JSContext+LGOProps.h"
#import "LGOWatchDog.h"

@implementation LGOJSMessage

+ (nullable LGOJSMessage *)newMessageWithJSONString:(nonnull NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (JSONData != nil) {
        NSError *err;
        NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&err];
        if (err == nil && [JSONObject isKindOfClass:[NSDictionary class]]) {
            LGOJSMessage *message = [[LGOJSMessage alloc] init];
            message.messageID = [JSONObject[@"messageID"] isKindOfClass:[NSString class]] ? JSONObject[@"messageID"] : nil;
            message.moduleName = [JSONObject[@"moduleName"] isKindOfClass:[NSString class]] ? JSONObject[@"moduleName"] : nil;
            message.requestParams = [JSONObject[@"requestParams"] isKindOfClass:[NSDictionary class]] ? JSONObject[@"requestParams"] : nil;
            message.callbackID = [JSONObject[@"callbackID"] isKindOfClass:[NSNumber class]] ? JSONObject[@"callbackID"] : nil;
            return message;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageID = @"";
        _moduleName = @"";
        _requestParams = @{};
        _callbackID = @(-1);
    }
    return self;
}

- (void)callWithCompletionBlock:(nonnull LGOJSMessageCallCompletionBlock)completionBlock context:(LGORequestContext *)context {
    LGOModule *module = [[LGOCore modules] moduleWithName:self.moduleName];
    if (module != nil) {
        LGORequestable *requestable = [module buildWithDictionary:self.requestParams context:context];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [requestable requestAsynchronize:^(LGOResponse * _Nonnull response) {
                if (response != nil) {
                    completionBlock([response toDictionary]);
                }
            }];
        }];
    }
}

@end

@implementation LGOJSBridge

+ (NSString *)bridgeScript {
    return @"var JSMessageCallbacks=[];var JSMessage={newMessage:function(name,requestParams){return{messageID:'',moduleName:name,requestParams:requestParams,callbackID:-1,call:function(callback){if(typeof callback=='function'){JSMessageCallbacks.push(callback);this.callbackID=JSMessageCallbacks.length-1}JSBridge.exec(JSON.stringify(this))},log:function(){console.log(this);JSConsole.log(JSON.stringify(this))}}}}";
}

+ (void)exec:(JSValue *)JSONString {
    LGOWebView *webView = JSONString.context.lgo_webView;
    if (webView == nil) {
        return;
    }
    NSURL *URL = webView.URL;
    if (URL == nil) {
        return;
    }
    if (![LGOWatchDog checkURL:URL] || ![LGOWatchDog checkSSL:URL]) {
        NSLog(@"Received an JSMessage request. It's domain not in white list. Request Failed.");
        return;
    }
    NSString *body = [JSONString toString];
    if (body != nil) {
        LGOJSMessage *message = [LGOJSMessage newMessageWithJSONString:body];
        if (message != nil) {
            if (![LGOWatchDog checkModule:URL moduleName:message.moduleName]) {
                NSLog(@"Received an JSMessage request. Module %@ require specific domain request.", message.moduleName);
                return;
            }
            LGORequestContext *context = [[LGORequestContext alloc] init];
            context.sender = webView;
            [message callWithCompletionBlock:^(NSDictionary<NSString *,id> * _Nonnull result) {
                [self callbackWithID:message.callbackID result:result webView:webView];
            } context:context];
        }
        else {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:body options:kNilOptions];
            if (data != nil) {
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (str != nil) {
                    NSLog(@"%@", str.stringByRemovingPercentEncoding);
                }
            }
            else {
                NSLog(@"%@", [body stringByRemovingPercentEncoding]);
            }
        }
    }
}

+ (void)log:(NSString *)text {
    NSLog(@"%@", text);
}

+ (void)callbackWithID:(NSNumber *)callbackID result:(NSDictionary *)result webView:(UIWebView *)webView {
    if (callbackID.integerValue >= 0 && [NSJSONSerialization isValidJSONObject:result] && webView != nil) {
        NSError *err;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:&err];
        if (err == nil && JSONData != nil) {
            NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSString *base64String = [[JSONString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
            if (base64String != nil) {
                [webView stringByEvaluatingJavaScriptFromString:
                 [NSString stringWithFormat:@"(function(){var JSONString = decodeURIComponent(atob('%@'));var JSCallbackParams = JSON.parse(JSONString);JSMessageCallbacks[%ld].call(null, JSCallbackParams)})()", base64String, (long)callbackID.integerValue]
                 ];
            }
        }
    }
}

@end

@implementation LGOJavaScriptBridge

+ (void)configureWithJSContext:(JSContext *)context {
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"%@", [value toString]);
    }];
    [context setObject:[LGOJSBridge class] forKeyedSubscript:@"JSConsole"];
    [context setObject:[LGOJSBridge class] forKeyedSubscript:@"JSBridge"];
}

@end
