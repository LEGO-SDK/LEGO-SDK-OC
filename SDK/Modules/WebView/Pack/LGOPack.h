//
//  LGOPack.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGOProtocols.h"

typedef void (^LGOPackFileServerProgressBlock)(double progress);
typedef void (^LGOPackFileServerCreatedBlock)(NSString *finalPath);

@interface LGOPack : LGOModule

+ (void)setPublicKey:(NSString *)publicKey forDomain:(NSString *)domain;

+ (void)setPublicKey:(NSString *)publicKey forURI:(NSString *)URI;

+ (void)createFileServerWithURL:(NSURL *)URL
                  progressBlock:(LGOPackFileServerProgressBlock)progressBlock
                completionBlock:(LGOPackFileServerCreatedBlock)completionBlock;

@end
