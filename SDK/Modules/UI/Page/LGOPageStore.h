//
//  LGOPageStore.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGOPageRequest;

@interface LGOPageStore : NSObject

+ (LGOPageStore *)sharedStore;

- (void)addItem:(LGOPageRequest *)request;

- (LGOPageRequest *)requestItem:(NSURL *)url;

@end
