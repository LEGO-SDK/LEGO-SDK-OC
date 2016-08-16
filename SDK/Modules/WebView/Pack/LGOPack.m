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
                                 indexFilename:@"index.html" cacheAge:0 allowRangeRequests:YES];
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

+ (void)createCacheDirectory {
    NSURL *cacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/LGOPack", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheURL path]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self cachePathWithURL:cacheURL] withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)createFileServerWithURL:(NSURL *)URL progressBlock:(LGOPackFileServerProgressBlock)progressBlock completionBlock:(LGOPackFileServerCreatedBlock)completionBlock {
    NSString *zipName = [URL lastPathComponent];
    [[NSOperationQueue new] addOperationWithBlock:^{
        BOOL noCache = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
            [SSZipArchive unzipFileAtPath:[self cachePathWithURL:URL]
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
        else if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]]) {
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
        else {
            noCache = YES;
        }
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?_t=%f",
                                                                             [[URL URLByAppendingPathExtension:@"hash"] absoluteString],
                                                                             [[NSDate date] timeIntervalSince1970]]]
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (data != nil) {
                                             NSString *md5 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                             if (md5 != nil && md5.length == 32 && ![self isSameWithMD5:md5 URL:URL]) {
                                                 [[[NSURLSession sharedSession]
                                                   downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?_t=%f",
                                                                                             [URL absoluteString],
                                                                                             [[NSDate date] timeIntervalSince1970]]]
                                                   completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       if (error == nil && location != nil) {
                                                           [self createCacheDirectory];
                                                           NSError *err;
                                                           [[NSFileManager defaultManager] removeItemAtPath:[self cachePathWithURL:URL] error:NULL];
                                                           [[NSFileManager defaultManager] copyItemAtPath:[location path] toPath:[self cachePathWithURL:URL] error:&err];
                                                           if (err == nil && noCache && [self isSameWithMD5:md5 URL:URL]) {
                                                               [self createFileServerWithURL:URL progressBlock:progressBlock completionBlock:completionBlock];
                                                           }
                                                       }
                                                 }] resume];
                                             }
                                         }
                                     }] resume];
    }];
}

+ (BOOL)isSameWithMD5:(NSString *)MD5 URL:(NSURL *)URL {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
        NSData *fileData = [NSData dataWithContentsOfFile:[self cachePathWithURL:URL]];
        if (fileData != nil) {
            return [[[CocoaSecurity md5WithData:fileData] hex] isEqualToString:[MD5 uppercaseString]];
        }
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:[URL lastPathComponent] ofType:@""]]) {
        NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[URL lastPathComponent] ofType:@""]];
        if (fileData != nil) {
            return [[[CocoaSecurity md5WithData:fileData] hex] isEqualToString:[MD5 uppercaseString]];
        }
    }
    return NO;
}

+ (NSString *)cachePathWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, [[CocoaSecurity md5:[URL absoluteString]] hex]];
}

+ (NSString *)fileServerPathWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@", NSTemporaryDirectory(), [[CocoaSecurity md5:[URL absoluteString]] hex]];
}

+ (NSString *)fileServerAddressWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"http://localhost:%d/%@/", serverPort, [[CocoaSecurity md5:[URL absoluteString]] hex]];
}

@end
