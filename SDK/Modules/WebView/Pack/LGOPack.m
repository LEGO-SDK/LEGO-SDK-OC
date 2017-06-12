//
//  LGOPack.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <GCDWebServer/GCDWebServer.h>
#import <SSZipArchive/SSZipArchive.h>
#import <CommonCrypto/CommonDigest.h>
#import "LGOPack.h"
#import "LGOCore.h"
#import "LGOPackRSA.h"

@implementation LGOPack

static GCDWebServer *sharedServer;
static NSMutableDictionary *sharedPublicKeys;
static int serverPort = 10000;

+ (void)load {
    [GCDWebServer setLogLevel:4];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedServer = [[GCDWebServer alloc] init];
      [sharedServer addGETHandlerForBasePath:@"/"
                               directoryPath:[NSString stringWithFormat:@"%@/LGOPack/", NSTemporaryDirectory()]
                               indexFilename:@"index.html"
                                    cacheAge:0
                          allowRangeRequests:YES];
      for (int i = serverPort; i < serverPort + 100; i++) {
          if ([sharedServer startWithPort:i bonjourName:nil]) {
              serverPort = i;
              break;
          }
      }
      sharedPublicKeys = [NSMutableDictionary dictionary];
    });
    [[LGOCore modules] addModuleWithName:@"WebView.Pack" instance:[self new]];
}

+ (void)setPublicKey:(NSString *)publicKey forDomain:(NSString *)domain {
    if (publicKey != nil && domain != nil) {
        [sharedPublicKeys setObject:publicKey forKey:domain];
    }
}

+ (void)setPublicKey:(NSString *)publicKey forURI:(NSString *)URI {
    if (publicKey != nil && URI != nil) {
        [sharedPublicKeys setObject:publicKey forKey:URI];
    }
}

+ (BOOL)localCachedWithURL:(NSURL *)URL {
    NSString *zipName = [URL lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
        return YES;
    }
    return NO;
}

+ (void)createCacheDirectory {
    NSURL *cacheURL =
        [NSURL URLWithString:[NSString stringWithFormat:@"%@/LGOPack", NSSearchPathForDirectoriesInDomains(
                                                                           NSCachesDirectory, NSUserDomainMask, YES)
                                                                           .firstObject]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheURL path]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self cachePathWithURL:cacheURL]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

+ (void)createFileServerWithURL:(NSURL *)URL
                  progressBlock:(LGOPackFileServerProgressBlock)progressBlock
                completionBlock:(LGOPackFileServerCreatedBlock)completionBlock {
    if ([[LGOCore whiteList] count] > 0) {
        [[LGOCore whiteList] addObject:@"localhost"];
    }
    NSString *zipName = [URL lastPathComponent];
    [[NSOperationQueue new] addOperationWithBlock:^{
      BOOL noCache = NO;
      if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
          [SSZipArchive unzipFileAtPath:[self cachePathWithURL:URL]
              toDestination:[self fileServerPathWithURL:URL]
              overwrite:YES
              password:nil
              progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  if (progressBlock) {
                      progressBlock((double)entryNumber / (double)total);
                  }
                }];
              }
              completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nonnull error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  completionBlock([self fileServerAddressWithURL:URL]);
                }];
              }];
      } else if ([[NSFileManager defaultManager]
                     fileExistsAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]]) {
          [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:zipName ofType:@""]
              toDestination:[self fileServerPathWithURL:URL]
              overwrite:YES
              password:nil
              progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  if (progressBlock) {
                      progressBlock((double)entryNumber / (double)total);
                  }
                }];
              }
              completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nonnull error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  completionBlock([self fileServerAddressWithURL:URL]);
                }];
              }];
      } else {
          noCache = YES;
      }
      [[[NSURLSession sharedSession]
            dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?_t=%f",
                                                                            [[URL URLByAppendingPathExtension:@"hash"]
                                                                                absoluteString],
                                                                            [[NSDate date] timeIntervalSince1970]]]
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (data != nil) {
                NSString *md5 = nil;
                if (URL.host != nil && [self requestPublicKey:URL] != nil) {
                    NSString *encodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if (encodedString != nil) {
                        md5 = [LGOPackRSA decryptString:encodedString publicKey:[self requestPublicKey:URL]];
                    }
                }
                if (md5 != nil && md5.length == 32 && ![self isSameWithMD5:md5 URL:URL]) {
                    [[[NSURLSession sharedSession]
                        downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?_t=%f",
                                                                                            [URL absoluteString],
                                                                                            [[NSDate date]
                                                                                                timeIntervalSince1970]]]
                          completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response,
                                              NSError *_Nullable error) {
                            if (error == nil && location != nil && [self isSameWithMD5:md5 fileURL:location]) {
                                [self createCacheDirectory];
                                NSError *err;
                                [[NSFileManager defaultManager] removeItemAtPath:[self cachePathWithURL:URL]
                                                                           error:NULL];
                                [[NSFileManager defaultManager] copyItemAtPath:[location path]
                                                                        toPath:[self cachePathWithURL:URL]
                                                                         error:&err];
                                if (err == nil && noCache) {
                                    [self createFileServerWithURL:URL
                                                    progressBlock:progressBlock
                                                  completionBlock:completionBlock];
                                }
                            }
                          }] resume];
                }
            }
          }] resume];
    }];
}

+ (NSString *)requestPublicKey:(NSURL *)URL {
    for (NSString *aKey in sharedPublicKeys) {
        if ([URL.absoluteString hasPrefix:aKey]) {
            return sharedPublicKeys[aKey];
        }
    }
    for (NSString *aKey in sharedPublicKeys) {
        if ([URL.host isEqualToString:aKey]) {
            return sharedPublicKeys[aKey];
        }
    }
    return nil;
}

+ (BOOL)isSameWithMD5:(NSString *)MD5 fileURL:(NSURL *)fileURL {
    NSData *fileData = [NSData dataWithContentsOfFile:[fileURL path]];
    if (fileData != nil) {
        return [[self requestMD5WithData:fileData] isEqualToString:[MD5 lowercaseString]];
    }
    return NO;
}

+ (BOOL)isSameWithMD5:(NSString *)MD5 URL:(NSURL *)URL {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:URL]]) {
        NSData *fileData = [NSData dataWithContentsOfFile:[self cachePathWithURL:URL]];
        if (fileData != nil) {
            return [[self requestMD5WithData:fileData] isEqualToString:[MD5 lowercaseString]];
        }
    } else if ([[NSFileManager defaultManager]
                   fileExistsAtPath:[[NSBundle mainBundle] pathForResource:[URL lastPathComponent] ofType:@""]]) {
        NSData *fileData =
            [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[URL lastPathComponent] ofType:@""]];
        if (fileData != nil) {
            return [[self requestMD5WithData:fileData] isEqualToString:[MD5 lowercaseString]];
        }
    }
    return NO;
}

+ (NSString *)cacheKey:(NSURL *)URL {
    return [self requestMD5WithString:[[URL.absoluteString componentsSeparatedByString:@"?"] firstObject]];
}

+ (NSString *)cachePathWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@",
                            NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,
                            [self cacheKey:URL]];
}

+ (NSString *)fileServerPathWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@", NSTemporaryDirectory(), [self cacheKey:URL]];
}

+ (NSString *)fileServerAddressWithURL:(NSURL *)URL {
    return [NSString stringWithFormat:@"http://localhost:%d/%@/", serverPort, [self cacheKey:URL]];
}

+ (NSString *)requestMD5WithString:(NSString *)str
{
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return [digest lowercaseString];
}

+ (NSString *)requestMD5WithData:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return [ret lowercaseString];
}

@end
