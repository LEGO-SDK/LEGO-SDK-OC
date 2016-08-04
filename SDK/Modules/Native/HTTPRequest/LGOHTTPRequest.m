//
//  LGOHTTPRequest.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOHTTPRequest.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOWebView.h"
#import "LGOWKWebView.h"

// - Request
@interface LGOHTTPRequestObject : LGORequest

@property (nonatomic, retain)NSMutableURLRequest *nativeRequest;
@property (nonatomic, assign)BOOL showActivityIndicator;
- (void)setTimeout:(double)time;
- (void)setHeaders:(NSDictionary *)headers;

@end

@implementation LGOHTTPRequestObject

- (instancetype)initWithURLString:(NSString *)URLString {
    self = [super init];
    if (self) {
        NSURL *URL = [[NSURL alloc] initWithString:URLString];
        if (URL) {
            _nativeRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
        }
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString data:(NSData *)data {
    self = [super init];
    if (self) {
        NSURL *URL = [[NSURL alloc] initWithString:URLString];
        if (URL) {
            _nativeRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
            _nativeRequest.HTTPMethod = @"POST";
            _nativeRequest.HTTPBody = data;
            _nativeRequest.HTTPShouldHandleCookies = false;
        }
    }
    return self;
}

- (void)setTimeout:(double)time{
    self.nativeRequest.timeoutInterval = time;
}

- (void)setHeaders:(NSDictionary *)headers{
    for (NSString *key in headers) {
        id val = [headers objectForKey:key];
        if ([val isKindOfClass:[NSString class]]){
            [self.nativeRequest setValue:(NSString *)val forHTTPHeaderField:key];
        }
    }
}

@end


// - Response
@interface LGOHTTPResponseObject : LGOResponse

@property (nonatomic, retain) NSString *error;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, retain) NSString *responseText;
@property (nonatomic, retain) NSData * _Nullable responseData;

@end

@implementation LGOHTTPResponseObject

- (NSDictionary *)toDictionary{
    return @{
             @"error": self.error,
             @"statusCode": [NSNumber numberWithInt:(self.statusCode)],
             @"responseText": self.responseText,
             @"responseData": ^(){
                 if (self.responseData){
                     return [self.responseData base64EncodedStringWithOptions:kNilOptions];
                 }
                 return @"";
             }()
             };
}

@end


// - Operation

@interface LGOHTTPOperation : LGORequestable

@property (nonatomic, retain) LGOHTTPRequestObject *request;

@end


@implementation LGOHTTPOperation

+ (NSOperationQueue *)aQueue{
    NSOperationQueue *q = [NSOperationQueue new];
    q.maxConcurrentOperationCount = 4;
    return q;
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock{
    if (self.request.showActivityIndicator){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    [NSURLConnection sendAsynchronousRequest:self.request.nativeRequest queue:[LGOHTTPOperation aQueue] completionHandler:^(NSURLResponse * _Nullable responseObject, NSData * _Nullable responseData, NSError * _Nullable error) {
        if (self.request.showActivityIndicator){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        LGOHTTPResponseObject * returnResponse = [LGOHTTPResponseObject new];
        returnResponse.error = error ? error.description : @"";
        returnResponse.statusCode = [responseObject isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)responseObject statusCode] : 500;
        NSString *utf8encodedString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (utf8encodedString){
            returnResponse.responseText = utf8encodedString;
            returnResponse.responseData = nil;
        }
        else{
            returnResponse.responseText = @"";
            returnResponse.responseData = responseData;
        }
        callbackBlock(returnResponse);
    }];
}

@end

// - Module

@implementation LGOHTTPRequest

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOHTTPRequestObject class]]){
        LGOHTTPOperation *operation = [LGOHTTPOperation new];
        operation.request = (LGOHTTPRequestObject *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    LGOHTTPRequestObject * _Nullable requestObject = nil;
    
    // resolve URLString
    NSString * _Nullable URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]]? dictionary[@"URL"] : nil;
    if (URLString){
        if (![URLString hasPrefix:@"http://"] && ![URLString hasPrefix:@"https://"]){
            if([context.requestWebView isKindOfClass:[LGOWebView class]]){
                LGOWebView *webView = (LGOWebView *)context.requestWebView;
                NSURL *activeURL = webView.URL;
                NSURL *relativeURL = [NSURL URLWithString:URLString relativeToURL:activeURL];
                if (relativeURL){
                    URLString = relativeURL.absoluteString;
                }
            }
            if([context.requestWebView isKindOfClass:[LGOWKWebView class]]){
                LGOWKWebView *webView = (LGOWKWebView *)context.requestWebView;
                NSURL *activeURL = webView.URL;
                NSURL *relativeURL = [NSURL URLWithString:URLString relativeToURL:activeURL];
                if (relativeURL){
                    URLString = relativeURL.absoluteString;
                }
            }
        }
        
        NSString * _Nullable data = [dictionary[@"data"] isKindOfClass:[NSString class]] ? dictionary[@"data"] : nil;
        if (data){
            NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:data options:kNilOptions];
            if (base64Data){
                requestObject = [[LGOHTTPRequestObject alloc] initWithURLString:URLString data:base64Data];
            }
            else{
                NSData *encodedData = [data dataUsingEncoding:NSUTF8StringEncoding];
                if (encodedData) {
                    requestObject = [[LGOHTTPRequestObject alloc] initWithURLString:URLString data:encodedData];
                }
            }
        }
        else {
            requestObject = [[LGOHTTPRequestObject alloc] initWithURLString:URLString];
        }
    }
    
    if (requestObject){
        
        requestObject.showActivityIndicator = ^{
            NSNumber *isShow = dictionary[@"showActivityIndicator"];
            if ([isShow isKindOfClass:[NSNumber class]]){
                return isShow.boolValue;
            }
            return NO;
        }();
        
        NSNumber *timeout = dictionary[@"timeout"];
        if ([timeout isKindOfClass:[NSNumber class]]){
            [requestObject setTimeout:timeout.doubleValue];
        }
        
        NSDictionary *customHeaders = dictionary[@"headers"];
        if ([customHeaders isKindOfClass:[NSDictionary class]]){
            [requestObject setHeaders:customHeaders];
        }
        
        LGOHTTPOperation *operation = [LGOHTTPOperation new];
        operation.request = requestObject;
        return operation;
    }
    
    return [LGOBuildFailed new];
}

@end






