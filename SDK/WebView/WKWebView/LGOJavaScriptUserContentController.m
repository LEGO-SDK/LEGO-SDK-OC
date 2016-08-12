//
//  LGOJavaScriptUserContentController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOJavaScriptUserContentController.h"
#import "LGOProtocols.h"
#import "LGOCore.h"
#import "LGOWatchDog.h"

@implementation LGOWKMessage

+ (nullable LGOWKMessage *)newMessageWithJSONString:(nonnull NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (JSONData != nil) {
        NSError *err;
        NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&err];
        if (err == nil && [JSONObject isKindOfClass:[NSDictionary class]]) {
            LGOWKMessage *message = [[LGOWKMessage alloc] init];
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

- (void)callWithCompletionBlock:(nonnull LGOWKMessageCallCompletionBlock)completionBlock context:(LGORequestContext *)context {
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

@implementation LGOJavaScriptUserContentController

- (void)dealloc {
    [self removeScriptMessageHandlerForName:@"JSMessage"];
    [self removeScriptMessageHandlerForName:@"JSLog"];
    [self removeScriptMessageHandlerForName:@"JSLoaded"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addBridgeScript];
        [self addHandlers];
    }
    return self;
}

- (void)addPrescripts {
    [self addSynchronizeResponses:self.webView];
    [self addAssignArgs:self.webView];
}

- (void)addBridgeScript {
    [self addUserScript:[[WKUserScript alloc] initWithSource:@"var JSMessageCallbacks=[];var JSSynchronizeResponses={};var JSMessage={newMessage:function(name,requestParams){return{messageID:'',moduleName:name,requestParams:requestParams,callbackID:-1,call:function(callback){if(typeof callback=='function'){JSMessageCallbacks.push(callback);this.callbackID=JSMessageCallbacks.length-1}window.webkit.messageHandlers.JSMessage.postMessage(JSON.stringify(this));if(JSSynchronizeResponses[this.moduleName]!==undefined){return JSSynchronizeResponses[this.moduleName]}}}}}" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];
    [self addUserScript:[[WKUserScript alloc] initWithSource:@"var JSConsole={log:function(text){window.webkit.messageHandlers.JSLog.postMessage(btoa(encodeURIComponent(text)))}}" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];
    [self addUserScript:[[WKUserScript alloc] initWithSource:@"window.addEventListener('load', function(){window.webkit.messageHandlers.JSLoaded.postMessage('')})" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)addSynchronizeResponses:(UIView *)webView {
    for (NSString *moduleName in [LGOCore.modules allModules]) {
        LGOModule *module = [LGOCore.modules moduleWithName:moduleName];
        NSDictionary* syncDict = [module synchronizeResponse:webView];
        if (syncDict != nil) {
            NSError *error = nil;
            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:syncDict options:kNilOptions error:&error];
            if (error != nil ) { continue ; }
            NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            if (JSONString == nil) { continue ; }
            JSONString = [JSONString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            if (JSONString == nil) { continue ; }
            NSData *JSONData2 =  [JSONString dataUsingEncoding:NSUTF8StringEncoding];
            if (JSONData2 == nil) {continue ;}
            NSString *base64String = [JSONData2 base64EncodedStringWithOptions:kNilOptions];
            [self addUserScript:[[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"JSSynchronizeResponses['%@'] = JSON.parse(decodeURIComponent(atob('%@')));", moduleName, base64String] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];
        }
    }
}

- (void)addAssignArgs:(UIView *)webView {
    if ([webView isKindOfClass:[WKWebView class]]) {
        if ([webView respondsToSelector:NSSelectorFromString(@"lgo_args")]) {
            NSDictionary *args = [webView valueForKey:@"lgo_args"];
            if (args != nil) {
                NSError *error = nil;
                NSData *JSONData = [NSJSONSerialization dataWithJSONObject:args options:kNilOptions error:&error];
                if (error == nil ) {
                    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
                    if (JSONString != nil) {
                        JSONString = [JSONString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        if (JSONString != nil) {
                            NSData *JSONData2 =  [JSONString dataUsingEncoding:NSUTF8StringEncoding];
                            if (JSONData2 != nil) {
                                NSString *base64String = [JSONData2 base64EncodedStringWithOptions:kNilOptions];
                                [self addUserScript:[[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"window._args = {}; Object.assign(window._args, JSON.parse(decodeURIComponent(atob('%@'))));", base64String] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];
                            }
                        }
                    }
                }
                
            }
        }
    }
}

- (void)addHandlers {
    [self addScriptMessageHandler:self name:@"JSMessage"];
    [self addScriptMessageHandler:self name:@"JSLog"];
    [self addScriptMessageHandler:self name:@"JSLoaded"];
}

- (void)callbackWithID:(NSNumber *)callbackID result:(NSDictionary *)result {
    WKWebView *webView = self.webView;
    if (callbackID.integerValue >= 0 && [NSJSONSerialization isValidJSONObject:result] && webView != nil) {
        NSError *err;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:&err];
        if (err == nil && JSONData != nil) {
            NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSString *base64String = [[JSONString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
            if (base64String != nil) {
                NSString *code = [NSString stringWithFormat:@"(function(){var JSONString = decodeURIComponent(atob('%@'));var JSCallbackParams = JSON.parse(JSONString);JSMessageCallbacks[%ld].call(null, JSCallbackParams)})()", base64String, (long)callbackID.integerValue];
                [webView evaluateJavaScript:code completionHandler:^(id _Nullable _, NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"%@", error);
                    }
                }];
            }
        }
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    WKWebView *webView = self.webView;
    if (webView == nil) {
        return;
    }
    if ([message.name isEqualToString:@"JSMessage"] || [message.name isEqualToString:@"JSLog"]) {
        NSURL *URL = webView.URL;
        if (URL == nil) {
            return;
        }
        if (![LGOWatchDog checkURL:URL] || ![LGOWatchDog checkSSL:URL]) {
            NSLog(@"Received an JSMessage request. It's domain not in white list. Request Failed.");
            return;
        }
        NSString *body = message.body;
        if (body != nil && [body isKindOfClass:[NSString class]]) {
            LGOWKMessage *message = [LGOWKMessage newMessageWithJSONString:body];
            if (message != nil) {
                if (![LGOWatchDog checkModule:URL moduleName:message.moduleName]) {
                    NSLog(@"Received an JSMessage request. Module %@ require specific domain request.", message.moduleName);
                    return;
                }
                LGORequestContext *context = [[LGORequestContext alloc] init];
                context.sender = webView;
                [message callWithCompletionBlock:^(NSDictionary<NSString *,id> * _Nonnull result) {
                    [self callbackWithID:message.callbackID result:result];
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
    else if ([message.name isEqualToString:@"JSLoaded"]) {
        
    }
}

@end
