//
//  LGOPageStateProtocol.h
//  LEGO-SDK-OC
//
//  Created by errnull on 2019/8/28.
//  Copyright © 2019 UED Center. All rights reserved.
//

#ifndef LGOPageStateProtocol_h
#define LGOPageStateProtocol_h

@protocol LGOPageStateProtocol <NSObject>

@optional

- (void)pageDidLoad;

- (void)pageWillAppear;
- (void)pageDidAppear;

- (void)pageWillDisappear;
- (void)pageDidDisappear;

- (void)pageDealloc;

@end

#endif /* LGOPageStateProtocol_h */
