//
//  LGOPack.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOPack.h"
#import <CocoaSecurity/CocoaSecurity.h>
#import <SSZipArchive/SSZipArchive.h>
#import <GCDWebServer/GCDWebServer.h>

@implementation LGOPack

static GCDWebServer *sharedServer;
static int serverPort = 10000;

+ (void)load {
    [GCDWebServer setLogLevel:4];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServer = [[GCDWebServer alloc] init];
        [sharedServer addGETHandlerForBasePath:@"/"
                                 directoryPath:[NSString stringWithFormat:@"%@/LGOPack/", NSTemporaryDirectory()]
                                 indexFilename:@"index.html" cacheAge:60 allowRangeRequests:YES];
        for (int i = serverPort; i < serverPort + 100; i++) {
            if ([sharedServer startWithPort:i bonjourName:nil]) {
                serverPort = i;
                break;
            }
        }
    });
}

+ (BOOL)localCachedWithURL:(NSURL *)URL {
    NSString *zipName = [URL lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]]) {
        return YES;
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
        return YES;
    }
    return NO;
}

+ (void)createFileServerWithURL:(NSURL *)URL progressBlock:(LGOPackFileServerProgressBlock)progressBlock completionBlock:(LGOPackFileServerCreatedBlock)completionBlock {
    NSString *zipName = [URL lastPathComponent];
    [[NSOperationQueue new] addOperationWithBlock:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]]) {
            [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]
                            toDestination:[self fileServerPathWithURL:URL]
                                overwrite:YES
                                 password:nil
                          progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                  if (progressBlock) {
                                      progressBlock((double)entryNumber / (double)total);
                                  }
                              }];
                          } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                  completionBlock([self fileServerAddressWithURL:URL]);
                              }];
                          }];
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
            
        }
        else {
            
        }
    }];
}

+ (NSString *)cachePathWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, NO).firstObject, [[CocoaSecurity md5:[URL absoluteString]] hex]];
}

+ (NSString *)fileServerPathWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@", NSTemporaryDirectory(), [[CocoaSecurity md5:[URL absoluteString]] hex]];
}

+ (NSString *)fileServerAddressWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"http://localhost:%d/%@/", serverPort, [[CocoaSecurity md5:[URL absoluteString]] hex]];
}

@end
