//
//  LGOPageState.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/6/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOProtocols.h"
#import "LGOPageStateProtocol.h"

@interface LGOPageState : LGOModule

+ (LGOPageState *)sharedInstance;

- (void)registerPageStateObserver:(id<LGOPageStateProtocol>)pageStateObserver;

@end
