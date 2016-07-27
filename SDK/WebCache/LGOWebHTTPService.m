//
//  LGOWebHTTPService.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebHTTPService.h"
#import "LGOCore.h"
#import <UIKit/UIKit.h>
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>

@interface LGOWebHTTPService ()

@property (nonatomic, assign) NSUInteger localPort;
@property (nonatomic, strong) GCDWebServer *server;

@end

@implementation LGOWebHTTPService

+ (NSURLRequest *)proxyRequest:(NSURLRequest *)originRequest {
    NSMutableURLRequest *mutableRequest = [originRequest mutableCopy];
    NSURL *URL = originRequest.URL;
    if (URL != nil) {
        NSString *localDomain = [NSString stringWithFormat:@"http://localhost:%ld/", (long)[[[LGOCore webCache] HTTPService] localPort]];
        NSString *URLString = [URL.absoluteString stringByReplacingOccurrencesOfString:localDomain withString:@"http://"];
        if ([URLString rangeOfString:@"https://"].location != NSNotFound) {
            mutableRequest.URL = [NSURL URLWithString:[URLString stringByReplacingCharactersInRange:[URLString rangeOfString:@"https://"]
                                                                                         withString:[NSString stringWithFormat:@"%@_ssl_/", localDomain]]];
        }
        else if ([URLString rangeOfString:@"http://"].location != NSNotFound) {
            mutableRequest.URL = [NSURL URLWithString:[URLString stringByReplacingCharactersInRange:[URLString rangeOfString:@"http://"] withString:localDomain]];
        }
    }
    return [mutableRequest copy];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _server = [[GCDWebServer alloc] init];
    }
    return self;
}

- (void)startService {
    [self.server addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
        NSString *path = request.URL.path;
        if (path == nil) {
            return [GCDWebServerResponse responseWithStatusCode:500];
        }
        NSURL *URL;
        {
            if ([path hasPrefix:@"/_ssl_/"]) {
                URL = [NSURL URLWithString:[path stringByReplacingOccurrencesOfString:@"/_ssl_/" withString:@"https://"]];
            }
            else {
                URL = [NSURL URLWithString:[NSString stringWithFormat:@"http:/%@", path]];
            }
        }
        if (URL == nil) {
            return [GCDWebServerResponse responseWithStatusCode:500];
        }
        NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
        [URLRequest setHTTPMethod:@"GET"];
        [request.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [URLRequest setValue:obj forHTTPHeaderField:key];
        }];
        NSURLResponse *response;
        NSError *err;
        NSData *data = [NSURLConnection sendSynchronousRequest:URLRequest returningResponse:&response error:&err];
        if (err == nil) {
            return [GCDWebServerDataResponse responseWithData:data contentType:response.MIMEType];
        }
        else {
            return [GCDWebServerResponse responseWithStatusCode:500];
        }
    }];
    [self.server addDefaultHandlerForMethod:@"POST" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
        NSString *path = request.URL.path;
        if (path == nil) {
            return [GCDWebServerResponse responseWithStatusCode:500];
        }
        NSURL *URL;
        {
            if ([path hasPrefix:@"/_ssl_/"]) {
                URL = [NSURL URLWithString:[path stringByReplacingOccurrencesOfString:@"/_ssl_/" withString:@"https://"]];
            }
            else {
                URL = [NSURL URLWithString:[NSString stringWithFormat:@"http:/%@", path]];
            }
        }
        if (URL == nil) {
            return [GCDWebServerResponse responseWithStatusCode:500];
        }
        NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
        [URLRequest setHTTPMethod:@"GET"];
        [request.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [URLRequest setValue:obj forHTTPHeaderField:key];
        }];
        if ([(GCDWebServerDataRequest *)request hasBody]) {
            [URLRequest setHTTPBody:[(GCDWebServerDataRequest *)request data]];
        }
        NSURLResponse *response;
        NSError *err;
        NSData *data = [NSURLConnection sendSynchronousRequest:URLRequest returningResponse:&response error:&err];
        if (err == nil) {
            return [GCDWebServerDataResponse responseWithData:data contentType:response.MIMEType];
        }
        else {
            return [GCDWebServerResponse responseWithStatusCode:500];
        }
    }];
    for (NSUInteger i = self.localPort; i < self.localPort + 50; i++) {
        if ([self.server startWithPort:i bonjourName:nil]) {
            self.localPort = i;
            break;
        }
    }
}

@end
